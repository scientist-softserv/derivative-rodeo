# frozen_string_literal: true

require 'derivative/rodeo/chain'
require 'derivative/rodeo/storage_adapters'
require 'derivative/rodeo/queue_adapters'

module Derivative
  module Rodeo
    ##
    # The {Arena} is the "place" where the rodeo happens...for a single original file.
    #
    # The {Arena} class is responsible for ensuring that for a given {Manifest} and its
    # many possible {Manifest::Derived} objects we process the original file and derivatives in the
    # same arena.
    #
    # @see .for_pre_processing
    #
    # @note
    #
    #   This class was originally named Environment.  However that could be confusing when we have a
    #   {Configuration} that will definitely use `ENV` for secrets.  Instead, this class name
    #   leverages one of the terms from the American Rodeo, the arena, where the events happen.  I
    #   had thought of naming it Context but that was less descriptive.  Besides, wouldn't a little
    #   Hyrax in a cowboy hat holding a lasso riding a Bulkrax be a rather cool hexagonal sticker?
    #   I think so.
    #
    # rubocop:disable Metrics/ClassLength
    class Arena
      ##
      # @api public
      #
      # @param manifest [Derivative::Rodeo::Manifest::PreProcess]
      # @param config [Derivative::Rodeo::Configuration]
      def self.for_pre_processing(manifest:, config: Rodeo.config, &block)
        new(manifest: manifest,
            remote_storage: config.remote_storage,
            queue: config.queue,
            local_storage: config.local_storage,
            chain: Chain.for_pre_processing(config: config),
            logger: config.logger,
            config: config,
            &block)
      end

      ##
      # Create a new {Arena} based on the given :parent_arena for the derived file.
      #
      # @param parent_arena [Arena] where are we running things
      # @param derived_original_path [String] the path to the "original" file.
      # @param first_spawn_step_name [Symbol] the name of the "original" derivative, from which
      #        we'll generate subsequent derivatives.
      # @param index [Integer] the index of the derivative (for organizing within the :parent_arena)
      # @param derivatives [Array<#to_sym>] the derivatives to generate within the new {Arena}
      #
      # @return [Arena]
      def self.for_derived(parent_arena:, path_to_base_file_for_chain:, first_spawn_step_name:, index:, derivatives:)
        manifest = Manifest::Derived.new(original: parent_arena.manifest,
                                         first_spawn_step_name: first_spawn_step_name,
                                         index: index,
                                         derivatives: derivatives)
        chain = Chain.new(derivatives: derivatives)

        # As we move into derived files, we're making an assumption that there are no remote
        # versions of what we have.  Hence the shift to the null adapter.
        arena = new(manifest: manifest,
                    queue: parent_arena.queue,
                    local_storage: parent_arena.local_storage,
                    remote_storage: :null,
                    logger: parent_arena.logger,
                    config: parent_arena.config,
                    chain: chain)

        # We need to make sure that we're moving that newly minted derived file into the correct
        # storage bucket for this arena.
        arena.local_assign!(derivative: first_spawn_step_name, path: path_to_base_file_for_chain)
        arena
      end

      ##
      # It should be bi-directional:
      #
      # I can serialize a message via the {.to_json} method and unserialize via {.from_json}.
      #
      # Fundamentally this needs:
      #
      # - a manifest: The thing from which we can generate a derivative
      # - a derivative: The name of the derivative we want to make
      # - the local storage information: Where are we storing things locally, with some idea of
      #   the specific folder location; which could be handled at the {Configuration} level plus
      #   the {Manifest}'s identifying information.
      # - the remote storage information: A bit more of a black box than the local, as it's a
      #   read-only system.
      # - the queue adapter: what is the adapter we're using; this also might include the queue
      #   name that we want to use; likely we're using the same adapter as what we have here but
      #   perhaps a different queue name (determined by the {Step})
      # - the chain: because we need to know what comes next after the current message.
      #
      # @see #to_json
      # @see https://github.com/scientist-softserv/derivative-rodeo/issues/1 Initial acceptance criteria
      #
      # @note
      #
      #   Other queues also likely have messages to send.  A consistent message helps with tight
      #   interfaces.
      #
      # @param json [String]
      # @param config [Derivative::Rodeo::Configuration]
      # rubocop:disable Metrics/MethodLength
      def self.from_json(json, config: Rodeo.config, &block)
        json = JSON.parse(json)
        manifest = Manifest.from(json.fetch('manifest'))
        derivative_to_process = json.fetch('derivative_to_process', :base_file_for_chain).to_sym

        derivatives = json.fetch('chain') { Chain.for_pre_processing(config: config) }.map(&:to_sym)
        chain = Chain.new(derivatives: derivatives + [derivative_to_process])

        new(
          manifest: manifest,
          local_storage: json.fetch('local_storage', config.local_storage),
          remote_storage: json.fetch('remote_storage', config.remote_storage),
          queue: json.fetch('queue', config.queue),
          derivative_to_process: derivative_to_process,
          chain: chain,
          logger: config.logger,
          config: config,
          &block
        )
      end
      # rubocop:enable Metrics/MethodLength

      private_class_method :new

      ##
      # @param manifest [Derivative::Rodeo::Manifest::Base]
      # @param local_storage [Symbol, Hash<Symbol,Object>, StorageAdapters::Base]
      # @param remote_storage [Symbol, Hash<Symbol,Object>, StorageAdapters::Base]
      # @param queue [Symbol, Hash<Symbol,Object>]
      # @param chain [Chain]
      # @param logger [Logger, Object<#debug, #info, #warn, #error, #fatal>]
      # @param config [Derivative::Rodeo::Configuration]
      #
      # @note
      #
      #   We have disabled the Metrics/ParameterLists and consider that acceptable because we have
      #   privatized the .new method.
      #
      # @see .for_pre_processing
      #
      # rubocop:disable Metrics/ParameterLists
      # rubocop:disable Metrics/MethodLength
      def initialize(manifest:, local_storage:, remote_storage:, queue:, chain:, logger:, config:, derivative_to_process: nil)
        @manifest = manifest
        @chain = chain
        @derivative_to_process = derivative_to_process || chain.first.to_sym
        @local_storage = StorageAdapters.for(manifest: manifest, adapter: local_storage)
        @remote_storage = StorageAdapters.for(manifest: manifest, adapter: remote_storage)
        @queue = QueueAdapters.for(adapter: queue)
        @logger = logger
        @config = config

        yield(self) if block_given?

        # rubocop:disable Style/GuardClause
        if dry_run?
          extend Rodeo::DryRun.for(method_names: [
                                     :local_assign!,
                                     :local_demand_path_for!,
                                     :local_exists?,
                                     :local_path,
                                     :local_read,
                                     :local_run_command!,
                                     :remote_exists?,
                                     :remote_fetch!,
                                     :remote_fetch
                                   ],
                                   contexts: dry_run_context,
                                   config: config)
        end
        # rubocop:enable Style/GuardClause
      end
      # rubocop:enable Metrics/ParameterLists
      # rubocop:disable Metrics/MethodLength

      # @return [Derivative::Rodeo::Manifest::Base]
      attr_reader :manifest

      # @return [Derivative::Rodeo::StorageAdapters::Base]
      attr_reader :local_storage

      # @return [Derivative::Rodeo::StorageAdapters::Base]
      attr_reader :remote_storage

      # @return [Derivative::Rodeo::QueueAdapters::Base]
      attr_reader :queue

      attr_reader :derivative_to_process

      # @return [Derivative::Rodeo::Chain]
      attr_reader :chain

      # @return [Logger, Object<#debug, #info, #warn, #error, #fatal>]
      attr_reader :logger

      # @return [Derivative::Rodeo::Configuration]
      attr_reader :config

      ##
      # A convenience method to pass along "primative" information regarding the arena.
      #
      # @return [Hash<Symbol, Hash>]
      def to_hash
        {
          chain: chain.map(&:to_sym),
          local_storage: local_storage.to_hash,
          manifest: manifest.to_hash,
          queue: queue.to_hash,
          remote_storage: remote_storage.to_hash
        }
      end

      ##
      # @see .from_json
      # @todo The :original is hard-coded; need to figure out that.
      def to_json(derivative_to_process: :base_file_for_chain, chain: self.chain)
        to_hash.merge(
          derivative_to_process: derivative_to_process.to_sym,
          chain: chain.map(&:to_sym)
        ).to_json
      end

      delegate :path_for_shell_commands, :exists?, :assign!, :path, :read, to: :local_storage, prefix: "local"
      delegate :exists?, to: :remote_storage, prefix: "remote"
      delegate :file_set_filename, :mime_type, :mime_type=, to: :manifest
      delegate :dry_run, :dry_run?, to: :config

      def process_derivative!
        Process.call(derivative: derivative_to_process, arena: self)
      end

      ##
      # Begin the derivating!
      def start_processing!
        # message = Derivative::Rodeo::Message.to_json(arena: arena, derivative: chain.first, queue: queue)
        # Rodeo.process_derivative(json: message)
        enqueue(derivative_to_process: chain.first)
      end

      ##
      # @param derivative [#to_sym]
      #
      # @return [Symbol] :end_of_chain when we are done processing this chain.
      # @raise [Derivative::Rodeo::Exceptions::UnknownDerivativeRequestForChainError] when the
      #        given :derivative is not part of the {Arena}'s {#chain}.
      def process_next_chain_link_after!(derivative:)
        index = chain.find_index(Derivative::Rodeo::Step(derivative))
        raise Exceptions::UnknownDerivativeRequestForChainError.new(chain: chain, derivative: derivative) unless index

        next_link = chain.to_a[index + 1]
        return :end_of_chain unless next_link
        enqueue(derivative_to_process: next_link)
      end

      def enqueue(derivative_to_process:)
        queue.enqueue(derivative_to_process: derivative_to_process, arena: self)
      end

      private :enqueue

      ##
      # @param derivative [#to_sym]
      #
      # @note
      #
      #   Instead of relying on the delegate method and prefix, I want to ensure that the
      #   {#local_storage}'s fetch!! method receives the {#remote_storage} as the from: keyword.
      def remote_fetch(derivative:)
        local_storage.fetch(derivative: derivative, from: remote_storage)
      end

      ##
      # @param derivative [#to_sym]
      #
      # @note
      #
      #   Instead of relying on the delegate method and prefix, I want to ensure that the
      #   {#local_storage}'s fetch!! method receives the {#remote_storage} as the from: keyword.
      def remote_fetch!(derivative:)
        local_storage.fetch!(derivative: derivative, from: remote_storage)
      end

      ##
      # Delegate the local demand to the given :derivative.  The :derivative knows best.
      #
      # @param derivative [#to_sym]
      def local_demand_path_for!(derivative:)
        Rodeo.Step(derivative).demand_path_for!(manifest: manifest, storage: local_storage)
      end

      ##
      # A bit of indirection to create a common interface for running a shell command; and thus
      # allowing for introducing a dry-run to help in debugging/logging.
      #
      # @param command [String]
      #
      # @note
      #
      #   The name of this function follows the idioms of delegator prefix.  It could be that this
      #   function should be on the #local_storage object.
      def local_run_command!(command)
        `#{command}`
      end

      # @api private
      def dry_run_context
        {
          manifest: manifest,
          local_storage: local_storage.to_sym,
          remote_storage: remote_storage.to_sym,
          queue: queue.to_sym,
          chain: chain.to_a
        }
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end

# frozen_string_literal: true

module Derivative
  module Rodeo
    module StorageAdapters
      # A module to help document and describe the expected interface for a storage adapter.
      module Base
        ##
        # @param manifest [Derivative::Rodeo::Manifest]
        def initialize(manifest:)
          @manifest = Manifest.from(manifest)
        end

        ##
        # @return [Derivative::Rodeo::Manifest]
        attr_reader :manifest

        ##
        # @api private
        #
        # Assign the file at the given :path to the given :derivative.  That might mean copying the
        # file to the expected storage location.
        #
        # @param derivative [Symbol]
        # @param path [String]
        #
        # @see assign!
        def assign(derivative:, path:)
          raise NotImplementedError, "#{self.class}#assign"
        end

        ##
        # @api public
        #
        # Assign the file at the given :path to the given :derivative.  That might mean copying the
        # file to the expected storage location.
        #
        # @param derivative [Symbol]
        # @param path [String]
        #
        # @raise [Exceptions::DerivativeNotFoundError] when there is no :derivative in storage.
        #
        # @see #assign
        def assign!(derivative:, path:)
          demand_path_for!(derivative: derivative) do
            assign(derivative: derivative, path: path)
          end
        end

        ##
        # @api public
        # @param derivative [Symbol]
        #
        # @yield When the derivative does not exist, yield for additional processing to attempt to
        #        get the file there.
        # @yieldparam [String] path the path to where we'd want to put the binary derivative file.
        #
        # @raise [Exceptions::DerivativeNotFoundError] when there is no :derivative in storage.
        def demand_path_for!(derivative:)
          yield(path_to_storage(derivative: derivative)) if block_given? && !exists?(derivative: derivative)

          return path_to_storage(derivative: derivative) if exists?(derivative: derivative)

          raise Exceptions::DerivativeNotFoundError.new(derivative: derivative, storage: self)
        end

        ##
        # @api public
        #
        # @param derivative [Symbol]
        #
        # @return [TrueClass] when the given derivative exists in this storage.
        # @return [FalseClass] when the given derivative does not exist in this storage.
        def exists?(derivative:)
          raise NotImplementedError, "#{self.class}#exists?"
        end

        ##
        # This function writes the derivative into the storage, by fetching from the remote URL.
        #
        # @param derivative [Symbol]
        # @param from [StorageAdapters::Base]
        #
        # @return [String] the path to the resource in this storage instance.
        # @raise [Exceptions::DerivativeNotFoundError] when we were not able to successfully fetch
        #        and write the local file.
        # @see #fetch
        def fetch!(derivative:, from:)
          raise NotImplementedError, "#{self.class}#fetch!"
        end

        ##
        # @api public
        #
        # This function writes the derivative into the storage, by fetching from the remote URL.
        #
        # @param derivative [Symbol]
        # @param from [StorageAdapters::Base]
        #
        # @return [String] the path to the resource in this storage instance.
        # @return [FalseClass] when we do not successfully fetch and write the file locally.
        #
        # @see #fetch!
        def fetch(derivative:, from:)
          fetch!(derivative: derivative, from: from)
        rescue Exceptions::DerivativeNotFoundError
          false
        end

        ##
        # @api public
        #
        # @param derivative [Symbol]
        #
        # @return [String] The path to the storage of the given :derivative
        # @note A {Derivative::Rodeo::Manifest} has a #directory_slugs method; use that for getting
        #       the storage path.
        # @see #directory_name
        def path_to_storage(derivative:, **)
          raise NotImplementedError, "#{self.class}#path_to_storage"
        end
        alias path_to path_to_storage
        alias path path_to_storage

        ##
        # @api public
        #
        # @param derivative [Symbol]
        #
        # @return [String] The path to a version of the :derivative on which file system processes
        #         can operate.
        #
        # @note In some cases, this is different from the path
        # @see #directory_name
        def path_for_shell_commands(derivative:)
          raise NotImplementedError, "#{self.class}#path_for_shell_commands"
        end

        ##
        # @return [Symbol]
        #
        # By convention, all adapters have symbolic name.
        def to_sym
          self.class.to_s.demodulize.underscore.sub(/_adapter$/, '').to_sym
        end

        ##
        # @api public
        #
        # @return [Hash<Symbol, Object>]
        def to_hash
          { manifest: manifest.to_hash, name: to_sym }
        end
      end
    end
  end
end

# SpaceStone::Derivatives

The goal of `SpaceStone::Derivatives` is to provide interfaces and processing for files.

For a given parent identifier, an original filename, and a set of named derivatives (e.g. a [Manifest](./lib/space_stone/derivatives/manifest.rb)).  We want to find the named derivative, and failing that, generate the named derivative from the original filename.

There are two use cases for finding or creating:

1. Pre-processing
2. Ingesting

In both the *Pre-processing* and *Ingesting* cases, we will be given a [Manifest](./lib/space_stone/derivatives/manifest.rb) that describes the derivatives we want to either fetch from somewhere or, failing that, generate locally.

A primary difference is related to the strategies we use for fetching.  For the *Pre-processing* for a given named derivative (e.g. `:text`) we will use the provided URL for the `:text` derivative or will create the `:text` derivative.

For *Ingesting* we will check the [Repository](./lib/space_stone/derivatives/repository.rb) for the named `:text` derivative, failing that if there is a URL or file, we will use that, and failing that we will create the `:text` derivative.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add space_stone-derivatives

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install space_stone-derivatives

### Dependencies

  * [Tesseract-ocr](https://github.com/tesseract-ocr/)
  * [LibreOffice](https://www.libreoffice.org/)
  * [ghostscript](https://www.ghostscript.com/)
  * [poppler-utils](https://poppler.freedesktop.org/)
  * [ImageMagick](https://github.com/ImageMagick/ImageMagick6)
    - _ImageMagick policy XML may need to be more permissive in both resources and source media types allowed._
  * [libcurl3](https://packages.ubuntu.com/search?keywords=libcurl3)
  * [libgbm1](https://packages.debian.org/sid/libgbm1)

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jeremyf/space_stone-derivatives.

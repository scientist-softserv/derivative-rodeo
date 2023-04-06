# SpaceStone::Derivatives

The goal of `SpaceStone::Derivatives` is to provide interfaces  and processing for files.

We start from a [SpaceStone::Derivatives::Manifest::Original](./lib/space_stone/derivatives/manifest/original.rb), which is comprised of:

- a parent identifier
- an original filename
- a set of named derivatives; each named derivative might have path to a "known" already extisting file.

We process the original manifest in an [Environment](./lib/space_stone/derivatives/environment.rb).  During processing we might spawn multiple "child" processes from one derivative.  For example splitting a PDF into one image per page.  Each of those page images would then have their own [SpaceStone::Derivatives::Manifest::Derived](./lib/space_stone/derivatives/manifest/derived.rb) for further processing.

## Design Goals

`SpaceStone::Derivatives` is designed in such a way that it can run within an application or as part of a distributed architecture (e.g. AWS Lambdas).  Further, it is designed for extension and configuration; through well-documented interfaces and modular boundaries.

It is also designed to provide insight into configuration and failures through custom exceptions and logging.  It has a fail early mindset; first verifying that the desired derivatives don't creat circular dependencies; flattening those dependencies into a chain which we process one link at a time, via [SpaceStone::Derivatives::Process](./lib/space_stone/derivatives/process.rb).

Last, the test suite covers a significant portion of the code; exercising both unit tests and functional tests that can run on a developers machine to help ensure the desired behavior.

## Diagrams

TODO

## Installation

Install the gem  and add to the application's Gemfile by executing:

    $ bundle add space_stone-derivatives

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install space_stone-derivatives

### Dependencies

  * [Tesseract-ocr](https://github.com/tesseract-ocr/)
  * [LibreOffice](https://www.libreoffice.org/)
  * [ghostscript](https://www.ghostscript.com/)
  * [poppler-utils](https://poppler.freedesktop.org/)
  * [ImageMagick](https://github.com/ImageMagick/ImageMagick6)
    - _ImageMagick policy XML may need to be more permissive in both resources  and source media types allowed._
  * [libcurl3](https://packages.ubuntu.com/search?keywords=libcurl3)
  * [libgbm1](https://packages.debian.org/sid/libgbm1)

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`,  and then run `bundle exec rake release`, which will create a git tag for the version, push git commits  and the created tag,  and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jeremyf/space_stone-derivatives.

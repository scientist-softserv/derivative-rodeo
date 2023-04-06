# SpaceStone::Derivatives

The goal of `SpaceStone::Derivatives` is to provide interfaces and processing for files.

A [SpaceStone::Derivatives::Manifest::Original](./lib/space_stone/derivatives/manifest/original.rb) is a:

- parent identifier
- an original filename
- and a set of named derivatives

We process the original manifest in an [Environment](./lib/space_stone/derivatives/environment.rb).  Each derivative

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

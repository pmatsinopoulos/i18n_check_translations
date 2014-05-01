# I18nCheckTranslations

It can help you find out which translations are missing from your Rails translations files.
So, it is basically a development utility.

## Installation

Add this line to your application's Gemfile:

    gem 'i18n_check_translations'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install i18n_check_translations

## Usage

Try on the command line:

    rake i18n:check[en,nl]

It will generate the file `i18n_check_translations.csv` with all the `en` (English) keys found in your translation files
that reside in the directory tree `config/locales`. For each key, will hold the translation in English, the translation in `nl`,
or a string starting from `translation missing` if the translation is missing, and the file that the translation is/was supposed
to be.

If you try:

    rake i18n:check[en,nl,true]

it will raise a `StandardError` exception when it will find a case in which the translation is missing.

If you try:

    rake i18n:check[en,nl,false,filename]

it will generate the file with name `filename` and save the results in it.

If you try:

    rake i18n::check[en]

or, in order words, if you omit the destination translation, task will run once for every available locale and will generate
a corresponding file. For example, if your available locales (excluding English in the example) were `:nl` and `:gr` you
would get the output in `i18n_check_translations-nl.csv` and in `i18n_check_translations-gr.csv`.

### If you are using RSpec

...And you want your specs to check for missing translations and fail for each key missing:

1. Add the following to your `spec_helper`

    require 'i18n_check_translations_rspec'

2. Write a `spec` file with the following content:

(assuming that you want to check against english basic locale)

    require 'spec_helper'

    describe 'Check for missing translations' do
      I18nCheckTranslations::RSpec.check_for_missing_translations(self, :en)
    end

This will automatically create one example for each english key and will fail for those keys that are missing translation
in any of the available locales (that are different to the basic locale given).

## Contributing

1. Fork it ( http://github.com/<my-github-username>/i18n_check_translations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

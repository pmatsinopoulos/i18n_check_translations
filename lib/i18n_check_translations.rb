require "i18n_check_translations/version"
load 'i18n_check_translations.rake'
require 'csv'

module I18nCheckTranslations
  # @param basic_locale {Symbol} e.g.: :en, :nl, :gr
  # @param check_on_locale {Symbol} e.g.: :en, :nl, :gr
  # @param raise_error_if_missing {true|false with default nil}
  #
  # @return {Hash} The result of processing the locales files for +basic_locale+ and trying to translate
  #                all the keys to the +check_on_locale+. See example below.
  #
  # It takes all the translation keys for the +basic_locale+ and tries to translate them
  # to +check_on_locale+. For those that are missing translations, it either write the
  # error or raises and Exception.
  #
  # Usage example:
  #
  #  1) result = I18nCheckTranslations.check :en, :nl
  #      will take all the *.en.yml files from config/locales and will build a
  #      a Hash with all the translation keys and their values on the :nl locale
  #      For example:
  #
  #      {"en.customer.first_name" => {:translation => "Voornaam",
  #                                    :basic_local_translation => "First Name",
  #                                    :localization_file => "/config/locales/customers/nl.yml"}}
  #     If the translation is missing for :nl, then you are going to see on :translation something that
  #     starts with "translation missing"
  #
  #  2) result = I18nCheckTranslations.check :en, :nl, true
  #
  #     Same as (1), but it will raise an error if a translation is missing
  #
  def self.check(basic_locale, check_on_locale, raise_error_if_missing = false)
    result = {}

    disable_fallbacks # if fallbacks are enabled, then missing translations will not be missing.

    previous_locale = I18n.locale # save the current locale in order to restore it at the end of the process
    I18n.locale = check_on_locale

    Dir.glob(File.join(Rails.root, 'config', 'locales', '**', "*#{basic_locale}.yml")).each do |localization_file|
      hash_input = YAML.load_file localization_file

      paths = hash_traverse hash_input # big stuff of the work is done here to build all the translation keys from a file.

      paths.each do |key, translation|
        key_to_translate = key.gsub /^#{basic_locale.to_s}\./, '' # - remove the "en." from "en.customer.first_name"
        new_key = "#{check_on_locale}.#{key_to_translate}"        # - and make it "nl.customer.first_name" to index the Hash result
        new_translation = I18n.translate key_to_translate         # - do the translation

        result[new_key] = {:translation => new_translation,
                           :basic_locale_translation => translation,
                           :localization_file => dest_localization_file(localization_file, basic_locale, check_on_locale)}

        raise StandardError.new("Missing translation! #{result[new_key].inspect}") if new_translation.start_with?('translation missing') && raise_error_if_missing
      end
    end

    I18n.locale = previous_locale # restore locale

    enable_fallbacks

    result
  end

  # Same as +I18nCheckTranslations.check+ but takes as input the +filename+ that will be used
  # to save the results into a csv file.
  #
  def self.check_and_dump(filename, basic_locale, check_on_locale, raise_error_if_missing = false)
    result = check(basic_locale, check_on_locale, raise_error_if_missing)
    CSV.open filename, 'wb', :force_quotes => true do |csv|
      csv << ['KEY', 'BASIC TRANSLATION', 'TRANSLATION', 'LOCALIZATION FILE']
      result.each do |k, v|
        csv << [k, v[:basic_locale_translation], v[:translation], v[:localization_file]]
      end
    end
  end

  private

  # We build the destination localization file from the source localication file.
  #
  # Hence, given a source file: 'config/locales/customers/en.yml'
  #              a basic locale: :en
  #              a check_on_locale: :nl
  #
  # becomes 'config/locales/customers/nl.yml'
  #
  # We also take care to remove any Rails root prefix. Makes the path to file
  # easier to read.
  #
  def self.dest_localization_file(source_localization_file, basic_locale, check_on_locale)
    source_localization_file.gsub(/#{Rails.root}/, '').gsub(/#{basic_locale}.yml$/, "#{check_on_locale}.yml")
  end

  def self.disable_fallbacks
    I18n.available_locales.each do |al|
      I18n.fallbacks.merge!({al => [al]})
    end
  end

  def self.enable_fallbacks
    I18n.available_locales.each do |al|
      I18n.fallbacks.merge!({al => [al, I18n.default_locale]})
    end
  end

  # Takes hashes like this:
  #
  # hash = {:en => {:hello => 'Hello',
  #                 :world => 'World',
  #                 :wonderful => {:another => "wonderful",
  #                                :what => "world"},
  #                 :what_to => {:do_it => {:i_will_not => 'what is that?',
  #                                         :you_will   => 'another one'},
  #                              :redo_it => 'hello redo it'}
  #                },
  #         :gr => {:there => 'hello 2',
  #                 :again => {:what => 'again what on earth'}}
  #       }
  #
  # and returns a Hash like:
  #
  # {
  #  'en.hello'                    => 'Hello',
  #  'en.world'                    => 'World',
  #  'en.wonderful.another'        => 'wonderful',
  #  'en.wonderful.what'           => 'world',
  #  'en.what_to.do_it.i_will_not' => 'what is that?',
  #  'en.what_to.do_it.you_will'   => 'another one',
  #  'en.what_to.redo_it'          => 'hello redo it',
  #
  #  'gr.there'                    => 'hello 2',
  #  'gr.again.what'               => 'again what on earth'
  # }
  #
  def self.hash_traverse(hash)
    parents = []
    paths = {}
    hash.keys.each do |k|
      paths = hash_traverse_root(hash, k, parents, paths)
    end
    paths
  end

  def self.hash_traverse_root(hash, k, parents, paths)
    if hash[k].is_a?(Hash)
      parents.push(k)
      hash = hash[k]
      hash.each do |k, v|
        hash_traverse_root(hash, k, parents, paths)
      end
      parents.pop
    elsif hash[k].is_a?(String)
      parents.push(k)
      path = parents.join(".")
      paths[path] = hash[k]
      parents.pop
    end
    paths
  end
end

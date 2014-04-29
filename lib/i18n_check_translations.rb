require "i18n_check_translations/version"
load 'i18n_check_translations.rake'
require 'csv'

module I18nCheckTranslations
  # Usage example:
  #
  #  result = I18nCheckTranslations.check :en, :nl
  def self.check(basic_locale, check_on_locale, raise_error_if_missing = false)
    result = {}
    disable_fallbacks
    previous_locale = I18n.locale
    I18n.locale = check_on_locale
    Dir.glob(File.join(Rails.root, 'config', 'locales', '**', "*#{basic_locale}.yml")).each do |localization_file|
      hash_input = YAML.load_file localization_file
      paths = hash_traverse hash_input
      paths.each do |key, translation|
        key_to_translate = key.gsub /^#{basic_locale.to_s}\./, ''
        new_key = "#{check_on_locale}.#{key_to_translate}"
        new_translation = I18n.translate key_to_translate
        result[new_key] = {:translation => new_translation,
                           :basic_locale_translation => I18n.translate(key_to_translate, :locale => basic_locale, :fallback => 'false'),
                           :localization_file => localization_file.gsub(/#{Rails.root}/, '').gsub(/#{basic_locale}.yml$/, "#{check_on_locale}.yml")}
        raise StandardError.new("Missing translation! #{result[new_key].inspect}") if new_translation.start_with?('translation missing') && raise_error_if_missing
      end
    end
    I18n.locale = previous_locale
    enable_fallbacks
    result
  end

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

  def self.hash_traverse(hash)
    parents = []
    paths = {}
    hash.keys.each do |k|
      paths = hash_traverse_root(hash, k, parents, paths)
    end
    paths
  end

  def self.disable_fallbacks
    I18n.available_locales.each do
      |al| I18n.fallbacks.merge!({al => [al]})
    end
  end

  def self.enable_fallbacks
    I18n.available_locales.each do
      |al| I18n.fallbacks.merge!({al => [al, I18n.default_locale]})
    end
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

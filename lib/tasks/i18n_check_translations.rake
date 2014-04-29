require 'i18n_check_translations'

desc "Check your locales for consistency and missing translations"
namespace :i18n do
  task :check, [:basic_locale, :check_on_locale, :raise_error_if_missing, :filename] => :environment do |t, args|
    basic_locale           = args[:basic_locale]
    check_on_locale        = args[:check_on_locale]
    raise_error_if_missing = args[:raise_error_if_missing].present? ? args[:raise_error_if_missing] == 'true' : false
    filename               = args[:filename]

    basic_locale = I18n.default_locale if basic_locale.nil?
    basic_locale = basic_locale.to_sym

    check_on_locale = :all if check_on_locale.blank?
    check_on_locale = check_on_locale.to_sym

    filename = File.join(Rails.root, 'i18n_check_translations.csv') if filename.nil?

    if check_on_locale == :all
      I18n.available_locales.select {|al| al != basic_locale}.each do |dest_locale|
        new_filename = filename.gsub /\.csv$/, "-#{dest_locale}.csv"
        I18nCheckTranslations.check_and_dump(new_filename, basic_locale, dest_locale, raise_error_if_missing)
      end
    else
      I18nCheckTranslations.check_and_dump(filename, basic_locale, check_on_locale, raise_error_if_missing)
    end
  end
end
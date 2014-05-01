module I18nCheckTranslations
  module RSpec
    # @param example {RSpec::Core::ExampleGroup}
    #
    # Dynamically creates the examples that will check for the keys. One example for each key.
    #
    def self.check_for_missing_translations(example, basic_locale)
      I18n.available_locales.reject {|al| al == basic_locale}.each do |available_locale|
        results = I18nCheckTranslations.check(basic_locale, available_locale)
        results.each do |key, value|
          test_name = "for key: #{key}, in localization_file: #{value[:localization_file]}"
          example.it test_name do
            expect(value[:translation].start_with?('translation missing')).to be_false
          end
        end
      end
    end
  end
end

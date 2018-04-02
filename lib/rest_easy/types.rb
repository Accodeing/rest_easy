require 'dry-struct'
require 'dry-types'

module RestEasy
  module Types
    include Dry::Types.module

    THE_TRUTH = { true => true, 'true' => true, false => false, 'false' => false }.freeze

    require 'rest_easy/types/required'
    require 'rest_easy/types/defaulted'
    require 'rest_easy/types/nullable'

    require 'rest_easy/types/enums'

    require 'rest_easy/types/sized'

    AccountNumber = Strict::Int.constrained( gteq: 0, lteq: 9999 ).optional

    ArticleType = Strict::String.constrained( included_in: ArticleTypes.values ).optional.constructor( EnumConstructors.default )

    CountryCode = Strict::String.constrained( included_in: CountryCodes.values ).optional.constructor( EnumConstructors.sized(2) )
    Currency = Strict::String.constrained( included_in: Currencies.values ).optional.constructor( EnumConstructors.sized(3) )
    CustomerType = Strict::String.constrained( included_in: CustomerTypes.values ).optional.constructor( EnumConstructors.default )

    DiscountType = Strict::String.constrained( included_in: DiscountTypes.values ).optional.constructor( EnumConstructors.default )

    Email = Strict::String.constrained( max_size: 1024, format: /\A^$|[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i ).optional.constructor{ |v| v.to_s.downcase unless v.nil? }

    HouseWorkType = Strict::String.constrained( included_in: HouseWorkTypes.values ).optional.constructor( EnumConstructors.default )

    VATType = Strict::String.constrained( included_in: VATTypes.values ).optional.constructor( EnumConstructors.default )

    DefaultDeliveryType = Strict::String.constrained( included_in: DefaultDeliveryTypeValues.values ).optional.constructor( EnumConstructors.default )

    ProjectStatusType = Strict::String.constrained( included_in: ProjectStatusTypes.values ).optional.constructor( EnumConstructors.default )

    require 'rest_easy/types/model'
  end
end

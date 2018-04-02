require 'rest_easy'
require 'rest_easy/mapper'

shared_context 'JSON conversion' do
  before do
    module Test
      class BaseMapper
      end

      class CategoryMapper < BaseMapper
        KEY_MAP = { id: 'ID' }.freeze
      end

      class ProductDesignerMapper < BaseMapper
        KEY_MAP = { id: 'ID' }.freeze
      end

      class ProductMapper < BaseMapper
        KEY_MAP = {
          vat: 'VAT',
          url: '@url' # TODO: How to handle url attribute?
        }.freeze
        JSON_ENTITY_WRAPPER = 'Product'.freeze
        JSON_COLLECTION_WRAPPER = 'Products'.freeze
      end

      class Category < RestEasy::Model
        attribute :name, 'strict.string'
        attribute :id, 'strict.string'
      end

      class ProductDesigner < RestEasy::Model
        attribute :name, 'strict.string'
        attribute :id, 'strict.string'
      end

      class Product < RestEasy::Model
        attribute :url, 'strict.string'
        attribute :name, 'strict.string'
        attribute :vat, 'strict.float'
        attribute :categories, Dry::Types['coercible.array'].member( Test::Category )
        attribute :designer, Test::ProductDesigner
      end
    end

    def register_mapper( mapper_sym, mapper )
      unless RestEasy::Registry.key? mapper_sym
        RestEasy::Registry.register( mapper_sym, mapper )
      end
    end

    register_mapper( :category, Test::CategoryMapper)
    register_mapper( :productdesigner, Test::ProductDesignerMapper )
    register_mapper( :product, Test::ProductMapper )
  end
end

class Product < ActiveRecord::Base
  attr_accessible :name, :description, :is_visible, :price, :sku, :collection_id, :lat, :lon, :zoom, :token, :in_stock_at

  belongs_to :collection

  has_one :picture, -> { where(is_main: true) }, as: :assetable, dependent: :destroy
  has_many :pictures, -> { where(is_main: false) }, as: :assetable, dependent: :destroy

  fileuploads :picture, :pictures
  translates :name, :description
  attr_accessible *all_translated_attribute_names

  scope :visible, -> { where(is_visible: true) }
  scope :un_visible, -> { where(is_visible: false) }

  include AbAdmin::Concerns::AdminAddition

  scope :admin, -> { includes(:translations, :picture) }

  alias_attribute :title, :name

  validates :sku, presence: true

  #include AbAdmin::Concerns::HasTracking

  def publish!
    update_column(:is_visible, true)
  end

  def un_publish!
    update_column(:is_visible, false)
  end

end

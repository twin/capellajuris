class Content < ActiveRecord::Base
  def self.by_page(page)
    where(:page => page)
  end

  before_create do
    unless order_no.present?
      self.order_no = Content.by_page(page).maximum(:order_no).to_i + 1
    end
  end

  before_save do
    if text.present?
      self.text = text.sub(/\<a [^\>]+\>(\<img [^\>]+\>)\<\/a\>/, '\1')
    end
  end
end

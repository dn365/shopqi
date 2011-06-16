#encoding: utf-8
class OrdersController < ApplicationController
  prepend_before_filter :authenticate_user!
  layout 'admin'

  expose(:shop) { current_user.shop }
  expose(:orders) do
    page_size = 25
    if params[:search]
      page_size = params[:search].delete(:limit) || page_size
      shop.orders.limit(page_size).metasearch(params[:search]).all
    else
      shop.orders.limit(page_size)
    end
  end
  expose(:order)
  expose(:orders_json) do
    orders.to_json({
      methods: [ :status_name, :financial_status_name, :fulfillment_status_name ],
      except: [ :updated_at ]
    })
  end
  expose(:status) { KeyValues::Order::Status.hash }
  expose(:financial_status) { KeyValues::Order::FinancialStatus.hash }
  expose(:fulfillment_status) { KeyValues::Order::FulfillmentStatus.hash }
  expose(:page_sizes) { KeyValues::PageSize.hash }

  # 批量修改
  def set
    operation = params[:operation].to_sym
    ids = params[:orders]
    if [:open, :close].include?(operation)
      value = (operation == :close) ? :closed : :open
      orders.find(ids).each do |order|
        order.update_attribute :status, value
      end
    else #支付授权
    end
    render nothing: true
  end
end
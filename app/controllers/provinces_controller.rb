class ProvincesController < ApplicationController
  def tax
    province = Province.find(params[:id])

    render json: {
      hst_rate: province.hst_rate,
      pst_rate: province.pst_rate
    }
  end
end
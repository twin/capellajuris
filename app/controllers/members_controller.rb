# encoding: utf-8
class MembersController < ApplicationController
  before_filter :handle_unauthorized_request

  def gui
    @members = Member.order(:last_name)
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.create(params[:member])

    if @member.valid?
      redirect_to members_path, :notice => "Novi član je uspješno dodan."
    else
      render :new
    end
  end

  def destroy
    member = Member.destroy(params[:id])
    redirect_to members_path, :notice => "Član \"#{member}\" je izbrisan."
  end
end

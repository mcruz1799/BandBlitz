class BandsController < ApplicationController
  before_action :set_band, only: [:show, :edit, :update, :destroy]
  #before_action :check_login, only: [:new, :edit, :update, :destroy]

  # GET /bands
  # GET /bands.json
  def index
    @bands = Band.alphabetical.to_a
  end

  # GET /bands/1
  # GET /bands/1.json
  def show
  end

  # GET /bands/new
  def new
    authorize! :new, @band
    @band = Band.new
  end

  # GET /bands/1/edit
  def edit
    authorize! :update, @band
  end

  # POST /bands
  # POST /bands.json
  def create
    authorize! :new, @band
    params[:band][:genre_ids] ? genres = params[:band][:genre_ids] : genres = Array.new
    @band = Band.new(band_params) if Band.check_genres(genres)

    if @band.save
      redirect_to(@band, :notice => 'Band was successfuly created.')
    else
      params[:band][:genre_ids] = nil
      render :action => 'new'
    end
  end

  # PATCH/PUT /bands/1
  # PATCH/PUT /bands/1.json
  def update
    authorize! :update, @band
    Band.check_genres(params[:band][:genre_ids])
    if @band.update_attributes(band_params)
      redirect_to(@band, :notice => 'Band was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /bands/1
  # DELETE /bands/1.json
  def destroy
    authorize! :destroy, @band
    @band.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_band
      @band = Band.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def band_params
      params.require(:band).permit(:name, :description, :playing_next, :when_playing_next, :photo, :song, :genre_ids => [])    
    end
end

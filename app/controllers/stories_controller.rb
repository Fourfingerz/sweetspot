Refile.host = ENV['REFILE_HOST']

class StoriesController < ApplicationController

  include Refile::AttachmentHelper
  before_action :authenticate_user!, :except => [:network, :path, :index, :show, :show_json]

  before_filter :find_story,  :only => [:network, :show, :edit, :update, :destroy]
  before_filter :reify_story, :only => [:show, :edit]

  respond_to :html, :json

  def path

  end

  def network
    nodes = []
    links = []

    @story.films.each do |photo|
      if !@story.name.nil?
        name = @story.name
      else
        name = 'Unnamed'
      end
      node = {
        name: name,
        group: photo.id
      }
      nodes << node
      photo.hotspots.each do |hotspot|
        link = {
          source: photo.id,
          target: hotspot.destination.to_i,
          value: 1
        }
        links << link
      end
    end
    datas = {
      nodes: nodes,
      links: links
    }

    render json: datas.to_json
  end

  def index
    # The `live` scope gives us widgets that aren't in the trash.
    # It's also strongly recommended that you eagerly-load the `draft` association via `includes` so you don't keep
    # hitting your database for each draft.
    @stories = Story.live.includes(:draft).order(:updated_at)

    # Load drafted versions of each widget
    # @stories.map! { |story| story.draft.reify if story.draft? }
    respond_with(@stories)
  end

  def show_json story_id
    story = Story.find(story_id)
    photos = story.films.all
    jphoto = []

    photos.each do |photo|
      jhotspots = []
      hotspots = photo.hotspots.all
      hotspots.each do |hotspot|
        location = []
        if !hotspot.location.nil?
          location = eval(hotspot.location)
        end
        jsweet = {
          coordinates: location,
          destination: hotspot.destination.to_i,
          updated_at: hotspot.updated_at
        }
        jhotspots << jsweet
      end
      image_url = nil
      if !attachment_url(photo, :image).nil?
        image_url = attachment_url(photo, :image) + '.jpeg'
      end
      jphoto << {
        id: photo.id,
        title: photo.title,
        description: photo.description,
        created_at: photo.created_at,
        updated_at: photo.updated_at,
        sweetspots: jhotspots,
        image_url: image_url,
      }
    end

    json = {
      story: {
        name: story.name,
        created_at: story.created_at,
        updated_at: story.updated_at,
        blurb: story.blurb,
        byline: story.byline,
        featured: story.featured_photo.to_i,
        first_slide: story.first_slide.to_i
      },
      photos: jphoto
    }
    return json
  end

  def show
    if @story.featured_photo.nil?
      @featured_image = @story.films.first
    else
      @featured_image = Film.find(@story.featured_photo.to_i)
    end
    respond_to do |format|
      format.html
      format.json { render json: show_json(@story.id) }
    end
    @film = @story.films.new
  end

  def new
    @story = Story.new
    respond_with(@story)
  end

  def edit
  end

  def create
    @story = Story.new(story_params)

    if @story.draft_creation
      flash[:success] = 'A draft of the new story was saved successfully.'
      redirect_to story_path
    else
      flash[:error] = 'There was an error creating the story. Please review the errors below and try again.'
      render :new
    end
  end

  def update

    @story.attributes = story_params

    # Instead of calling `update_attributes`, you call `draft_update` to save it as a draft
    if @story.draft_update
      flash[:success] = 'A draft of the story update was saved successfully.'
      redirect_to story_path
    else
      flash[:error] = 'There was an error updating the story. Please review the errors below and try again.'
      render :edit
    end
  end

  def destroy
    # Instead of calling `destroy`, you call `draft_destroy` to "trash" it as a draft
    @story.draft_destroy
    flash[:success] = 'The story was moved to the trash.'
    redirect_to story_path
  end

private

  # Finds non-trashed widget by `params[:id]`
  def find_story
    @story = Story.live.find(params[:id])
    @film = @story.films.new
    @films = @story.films.all
  end

  # If the widget has a draft, load that version of it
  def reify_story
    @story = @story.draft.reify if @story.draft?
  end

  def story_params
    params.require(:story).permit(:name, :first_slide, :featured_photo, :blurb, :byline)
  end
end

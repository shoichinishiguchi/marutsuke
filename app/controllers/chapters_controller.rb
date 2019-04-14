class ChaptersController < ApplicationController

  def show
    set_chapter_section
    respond_to do |format|
      format.html{
      redirect_to action: :root
      }
      format.json
    end
  end

  def new

  end

  def edit
    
  end

  def create

  end

  def update

  end

  private

  def set_chapter_section
    if params[:chapterid]
      @chapter = Chapter.find(params[:chapterid])
      @sections = @chapter.sections
    end
  end

end

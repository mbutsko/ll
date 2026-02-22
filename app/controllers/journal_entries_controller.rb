class JournalEntriesController < ApplicationController
  def create
    @journal_entry = current_user.journal_entries.new(journal_entry_params)
    @journal_entry.recorded_at = Time.current
    @journal_entry.save
    redirect_to root_path
  end

  def edit
    @journal_entry = current_user.journal_entries.includes(:labels).find(params[:id])
    @labels = Label.order(:name)
  end

  def update
    @journal_entry = current_user.journal_entries.find(params[:id])
    if @journal_entry.update(journal_entry_params)
      redirect_to root_path, notice: "Journal entry updated."
    else
      @labels = Label.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @journal_entry = current_user.journal_entries.find(params[:id])
    @journal_entry.destroy
    redirect_to root_path
  end

  private

  def journal_entry_params
    params.require(:journal_entry).permit(:body, label_ids: [])
  end
end

module Api
  class JournalEntriesController < BaseController
    def create
      entry = current_user.journal_entries.new(journal_entry_params)
      entry.recorded_at = params.dig(:journal_entry, :recorded_at) || Time.current

      if (slugs = params.dig(:journal_entry, :label_slugs)).present?
        entry.labels = Label.where(slug: Array(slugs))
      end

      if entry.save
        render json: {
          id: entry.id,
          body: entry.body,
          label_slugs: entry.labels.pluck(:slug),
          recorded_at: entry.recorded_at
        }, status: :created
      else
        render json: { error: entry.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    private

    def journal_entry_params
      params.require(:journal_entry).permit(:body)
    end
  end
end

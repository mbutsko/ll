class StreamController < ApplicationController
  def index
    types = Array(params[:types]).reject(&:blank?)
    types = %w[measurements food exercise journal] if types.empty?

    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil

    entries = []

    if types.include?("measurements")
      scope = current_user.measurements.includes(:metric)
      scope = scope.where(date: start_date..) if start_date
      scope = scope.where(date: ..end_date) if end_date
      scope.find_each do |m|
        entries << { type: "measurement", record: m, timestamp: m.date.beginning_of_day }
      end
    end

    if types.include?("food")
      scope = current_user.food_logs.includes(:food)
      scope = scope.where(consumed_at: start_date.beginning_of_day..) if start_date
      scope = scope.where(consumed_at: ..end_date.end_of_day) if end_date
      scope.find_each do |fl|
        entries << { type: "food", record: fl, timestamp: fl.consumed_at }
      end
    end

    if types.include?("exercise")
      scope = current_user.exercise_logs.includes(:exercise)
      scope = scope.where(performed_at: start_date.beginning_of_day..) if start_date
      scope = scope.where(performed_at: ..end_date.end_of_day) if end_date
      scope.find_each do |el|
        entries << { type: "exercise", record: el, timestamp: el.performed_at }
      end
    end

    if types.include?("journal")
      scope = current_user.journal_entries.includes(:labels)
      scope = scope.where(recorded_at: start_date.beginning_of_day..) if start_date
      scope = scope.where(recorded_at: ..end_date.end_of_day) if end_date
      scope.find_each do |je|
        entries << { type: "journal", record: je, timestamp: je.recorded_at }
      end
    end

    if start_date || end_date
      @entries = entries.sort_by { |e| e[:timestamp] }
    else
      @entries = entries.sort_by { |e| e[:timestamp] }.reverse
    end

    @active_types = types
    @start_date = start_date
    @end_date = end_date
  end
end

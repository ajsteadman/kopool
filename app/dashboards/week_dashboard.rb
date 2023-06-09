require "administrate/base_dashboard"

class WeekDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    active_for_scoring: Field::Boolean,
    deadline: Field::DateTime,
    default_team: Field::BelongsTo,
    end_date: Field::DateTime,
    matchups: Field::HasMany,
    open_for_picks: Field::Boolean,
    picks: Field::HasMany,
    season: Field::BelongsTo,
    start_date: Field::DateTime,
    week_number: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    active_for_scoring
    deadline
    default_team
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    active_for_scoring
    deadline
    default_team
    end_date
    matchups
    open_for_picks
    picks
    season
    start_date
    week_number
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    active_for_scoring
    deadline
    default_team
    end_date
    matchups
    open_for_picks
    picks
    season
    start_date
    week_number
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how weeks are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(week)
    "Week ##{week.week_number}"
  end
end

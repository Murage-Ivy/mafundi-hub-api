class Task < ApplicationRecord
  belongs_to :client
  belongs_to :service

  has_one :location, as: :locationable, dependent: :destroy
  accepts_nested_attributes_for :location

  validates :task_description, presence: true
  validates :job_price, presence: true
  validates :job_title, presence: true
  validates :location, presence: true

  validates :task_description, uniqueness: { scope: :client_id, message: "You already have a task with this description." }
end

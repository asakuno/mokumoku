# frozen_string_literal: true

class Event < ApplicationRecord
  include Notifiable
  belongs_to :prefecture
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :commented_users, through: :comments, class_name: 'User', source: :user
  has_many :attendances, dependent: :destroy, class_name: 'EventAttendance'
  has_many :attendees, through: :attendances, class_name: 'User', source: :user
  has_many :bookmarks, dependent: :destroy
  has_one_attached :thumbnail

  scope :future, -> { where('held_at > ?', Time.current) }
  scope :past, -> { where('held_at <= ?', Time.current) }
  scope :woman, -> { where('only_woman = ?', 1 ) }

  with_options presence: true do
    validates :title
    validates :content
    validates :held_at
  end

  def check_gender_woman(user)
    user.gender == "woman"
  end


  def check_only_woman?(event)
    event.only_woman == true  
  end

  def check(user)
    check_woman(user) || check_others(user)
  end

  def check_others(user)
    self.only_woman == false && user.gender == "lgtm" || self.only_woman == false && user.gender == "man"
  end

  def check_woman(user)
    self.only_woman == true && user.gender == "woman" || self.only_woman == false && user.gender == "woman"  
  end

  def past?
    held_at < Time.current
  end

  def future?
    !past?
  end
end

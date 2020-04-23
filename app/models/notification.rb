class Notification < ApplicationRecord
  after_create { NotificationRelayWorker.perform_async(self.id) }
  belongs_to :task, foreign_key: 'notifiable_id', required: true
  # belongs_to :notifiable, class_name: "Task"
  scope :unread, ->{where(read_at: nil)}

  def self.create_notification(notifiable_id, action)
    task=Task.find(notifiable_id)
    if action == "approved by"
      Notification.create(recipient_id: 1, user_id: task.assign_task_by, action: action, notifiable_type: "Task", notifiable_id:task.id)
    elsif action == "notified"
      User.where(hr: 1).each do |user|
        Notification.create(recipient_id: user.id, user_id: 1, action: action, notifiable_type: "Task", notifiable_id:task.id)
      end
    else
      Notification.create(recipient_id: task.user.id, user_id: task.assign_task_by, action: action, notifiable_type: "Task", notifiable_id:task.id)
    end
  end
end

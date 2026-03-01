from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import LeaveRequest
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

@receiver(post_save, sender=LeaveRequest)
def notify_leave_update(sender, instance, created, **kwargs):
    channel_layer = get_channel_layer()
    if created:
        message = f"New leave request from {instance.student.user.username}"
    else:
        message = f"Leave request for {instance.student.user.username} updated to {instance.status}"
    
    async_to_sync(channel_layer.group_send)(
        "leave_notifications",
        {
            "type": "send_leave_update",
            "message": message,
            "data": {
                "id": instance.id,
                "status": instance.status,
                "student": instance.student.user.username
            }
        }
    )

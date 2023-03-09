from django.db import models

class ongoing_payment(models.Model):
    order_id = models.CharField(max_length=256)
    pp_id = models.CharField(max_length=36)
    ref_id = models.CharField(max_length=256)
    amount = models.DecimalField(max_digits=10, decimal_places=2)

class completed_payment(models.Model):
    payer_id = models.CharField(max_length=256)
    payer_email = models.EmailField(default='personal_man@gmail.com')
    payer_fname = models.CharField(max_length=256)
    payer_lname = models.CharField(max_length=256)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.CharField(max_length=256)
    updated_at = models.CharField(max_length=256)
    
# Generated by Django 4.1.7 on 2023-03-08 16:28

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('PP', '0005_alter_completed_payment_created_at_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='completed_payment',
            name='payer_email',
            field=models.EmailField(default='personal_man@gmail.com', max_length=254),
        ),
        migrations.AlterField(
            model_name='completed_payment',
            name='amount',
            field=models.DecimalField(decimal_places=2, max_digits=10),
        ),
        migrations.AlterField(
            model_name='ongoing_payment',
            name='amount',
            field=models.DecimalField(decimal_places=2, max_digits=10),
        ),
    ]

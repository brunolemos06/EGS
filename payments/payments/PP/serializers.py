from rest_framework import serializers
from .models import completed_payment, ongoing_payment

class completed_paymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = completed_payment
        fields = '__all__'

        def save(self):
            return completed_payment.objects.create(**self.validated_data)
        
class ongoing_paymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = ongoing_payment
        fields = '__all__'

        def save(self):
            return ongoing_payment.objects.create(**self.validated_data)
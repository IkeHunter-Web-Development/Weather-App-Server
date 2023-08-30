"""
Views
Views convert the serialized models into json data, this is passed to the urls
"""

import json
from django.http import HttpResponse
from rest_framework import viewsets

from .serializers import PackageSerializer
from .models import Package


def health_check(request):
    payload = {
        'success': True,
        'message': 'Health check passed',
    }
    return HttpResponse(json.dumps(payload), content_type="application/json")

class PackageViewSet(viewsets.ModelViewSet):
    queryset = Package.objects.all().order_by('title')
    serializer_class = PackageSerializer

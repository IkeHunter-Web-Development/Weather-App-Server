# Generated by Django 3.2.18 on 2023-04-18 13:39

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('logic', '0011_auto_20230418_0126'),
    ]

    operations = [
        migrations.AddField(
            model_name='forecast',
            name='location',
            field=models.ForeignKey(default=0, on_delete=django.db.models.deletion.CASCADE, to='logic.summary'),
            preserve_default=False,
        ),
    ]

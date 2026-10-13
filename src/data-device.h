#pragma once
struct ElsewhereSeat;
struct ElsewhereDataDevice;
// Nested clipboard ownership; no host clipboard or D-Bus integration.
ElsewhereDataDevice* data_device_create(ElsewhereSeat* seat);
void data_device_destroy(ElsewhereDataDevice* data);
void data_device_focus(ElsewhereDataDevice* data);

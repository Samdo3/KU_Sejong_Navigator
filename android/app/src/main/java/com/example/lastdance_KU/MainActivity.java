package com.example.lastdance_KU;
import android.widget.Toast;
import android.content.pm.PackageManager;
import android.os.Bundle;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    private static final int LOCATION_PERMISSION_REQUEST_CODE = 1;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Check location permission on activity creation
        checkLocationPermission();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
            // Check if the permission was granted
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                showUserLocationOnMap();// Permission granted, 사용자 위치 표시
            } else {
                showPermissionDeniedMessage();// Permission denied, handle accordingly
            }
        }
    }

    private void checkLocationPermission() {
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION)
                != PackageManager.PERMISSION_GRANTED) {
            // Permission is not granted
            // You can ask for the permission at runtime
            ActivityCompat.requestPermissions(this,
                    new String[]{android.Manifest.permission.ACCESS_FINE_LOCATION},
                    LOCATION_PERMISSION_REQUEST_CODE);
        } else {
            showUserLocationOnMap();// Permission already granted, do something
        }
    }

    private void showUserLocationOnMap() {
        // Implement the logic to show the user's location on the map
    }

    private void showPermissionDeniedMessage() {
        // Customize this message according to your app's needs
        Toast.makeText(this, "Permission was denied", Toast.LENGTH_SHORT).show();
    }
}
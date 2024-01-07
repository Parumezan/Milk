import 'package:flutter/material.dart';

class StatusPainter extends CustomPainter {
  StatusPainter({required this.status});
  final String status;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 2,
        Paint()
          ..color = status == "RELEASING" ||
                  status == "QUEUED" ||
                  status == "DOWNLOADING" ||
                  status == "CONVERTING"
              ? Colors.blue
              : status == "FINISHED" || status == "AVAILABLE"
                  ? Colors.green
                  : status == "NOTAVAILABLE" || status == "NOTRELEASED"
                      ? Colors.red
                      : Colors.grey
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(StatusPainter oldDelegate) => true;
}

class StatusWidget extends StatelessWidget {
  const StatusWidget({required this.status, super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(10, 10),
      painter: StatusPainter(status: status),
    );
  }
}

String statusToString(String status) {
  switch (status) {
    case "NOTAVAILABLE":
      return "Not Available";
    case "NOTRELEASED":
      return "Not Released";
    case "NOTFOUND":
      return "Not Found";
    case "QUEUED":
      return "Queued";
    case "DOWNLOADING":
      return "Downloading";
    case "CONVERTING":
      return "Encoding";
    case "RELEASING":
      return "Releasing";
    case "FINISHED":
      return "Finished";
    case "AVAILABLE":
      return "Available";
    default:
      return "Unknown";
  }
}

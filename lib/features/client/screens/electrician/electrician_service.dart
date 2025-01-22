import 'package:flutter/material.dart';
import 'package:home_services/features/client/screens/Venders.dart';

class ElectricianServiceScreen extends StatefulWidget {
  @override
  _ElectricianServiceScreenState createState() => _ElectricianServiceScreenState();
}

class _ElectricianServiceScreenState extends State<ElectricianServiceScreen> {
  // Areas to service
  List<dynamic> _areas = [
    ['Living Room', 'https://img.icons8.com/officel/2x/living-room.png', Colors.red, 0],
    ['Bedroom', 'https://img.icons8.com/fluency/2x/bedroom.png', Colors.orange, 1],
    ['Bathroom', 'https://img.icons8.com/color/2x/bath.png', Colors.blue, 1],
    ['Kitchen', 'https://img.icons8.com/dusk/2x/kitchen.png', Colors.purple, 0],
    ['Office', 'https://img.icons8.com/color/2x/office.png', Colors.green, 0]
  ];

  List<int> _selectedAreas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Electrician Services'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Select areas to service:',
              style: TextStyle(
                fontSize: 30,
                color: Colors.grey.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _areas.length,
                itemBuilder: (BuildContext context, int index) {
                  return area(_areas[index], index);
                },
              ),
            ),
            if (_selectedAreas.isNotEmpty)
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  onPressed: () {
                    // Navigate to the Vendors screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Venders(),
                      ),
                    );
                  },
                  child: Icon(Icons.arrow_forward_ios, size: 18),
                  backgroundColor: Colors.blue,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget area(List area, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedAreas.contains(index)) {
            _selectedAreas.remove(index);
          } else {
            _selectedAreas.add(index);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        margin: EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: _selectedAreas.contains(index) ? area[2].shade50.withOpacity(0.5) : Colors.grey.shade100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(area[1], width: 35, height: 35),
                SizedBox(width: 10.0),
                Text(area[0], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                Spacer(),
                _selectedAreas.contains(index)
                    ? Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade100.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(Icons.check, color: Colors.green, size: 20),
                )
                    : SizedBox()
              ],
            ),
          ],
        ),
      ),
    );
  }
}

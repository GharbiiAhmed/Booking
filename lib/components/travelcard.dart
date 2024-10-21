import 'package:flutter/material.dart';

Widget travelCard(String imageUrl, String title, String location, int rating) {
  return Container(
    width: 200.0,
    margin: EdgeInsets.only(right: 16.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15.0),
      gradient: LinearGradient(
        colors: [Colors.lightBlueAccent, Colors.white70],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 5,
          blurRadius: 10,
          offset: Offset(0, 4), // changes position of shadow
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          child: Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            height: 120.0,
            width: double.infinity,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                location,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 6.0),
              Row(
                children: List.generate(rating, (index) {
                  return Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16.0,
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

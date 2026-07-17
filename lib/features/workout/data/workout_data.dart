import 'package:flutter/material.dart';
import '../models/workout.dart';

const List<Workout> workoutData = [
  Workout(
    title: 'Push Up',
    durationMinutes: 10,
    difficulty: 'Mudah',
    calories: 50,
    icon: Icons.fitness_center,
    description:
    'Push Up ialah senaman asas yang menguatkan bahagian dada, bahu dan lengan.',
    steps: [
      'Letakkan kedua-dua tangan sedikit lebih lebar daripada bahu.',
      'Luruskan badan dari kepala hingga kaki.',
      'Turunkan badan sehingga dada hampir menyentuh lantai.',
      'Tolak badan kembali ke posisi asal.',
      'Ulang mengikut kemampuan.',
    ],
    benefits: [
      'Menguatkan dada.',
      'Menguatkan bahu.',
      'Menguatkan trisep.',
      'Meningkatkan kestabilan badan.',
    ],
    tip: 'Pastikan belakang sentiasa lurus semasa melakukan Push Up.',
  ),

  Workout(
    title: 'Squat',
    durationMinutes: 15,
    difficulty: 'Mudah',
    calories: 70,
    icon: Icons.accessibility_new,
    description:
    'Squat membantu menguatkan otot kaki dan punggung.',
    steps: [
      'Buka kaki seluas bahu.',
      'Turunkan pinggul seperti hendak duduk.',
      'Pastikan lutut tidak melepasi hujung kaki.',
      'Tolak badan naik semula.',
    ],
    benefits: [
      'Menguatkan paha.',
      'Menguatkan punggung.',
      'Meningkatkan keseimbangan.',
    ],
    tip: 'Pastikan tumit sentiasa menyentuh lantai.',
  ),

  Workout(
    title: 'Plank',
    durationMinutes: 5,
    difficulty: 'Sederhana',
    calories: 30,
    icon: Icons.self_improvement,
    description:
    'Plank menguatkan otot teras dan membantu postur badan.',
    steps: [
      'Sokong badan menggunakan siku dan hujung kaki.',
      'Pastikan badan lurus.',
      'Tahan posisi selama mungkin.',
    ],
    benefits: [
      'Menguatkan core.',
      'Meningkatkan postur.',
      'Mengurangkan risiko sakit belakang.',
    ],
    tip: 'Jangan biarkan pinggul terlalu tinggi atau terlalu rendah.',
  ),

  Workout(
    title: 'Jumping Jack',
    durationMinutes: 10,
    difficulty: 'Mudah',
    calories: 80,
    icon: Icons.directions_run,
    description:
    'Jumping Jack ialah senaman kardio yang mudah dilakukan.',
    steps: [
      'Berdiri tegak.',
      'Lompat sambil membuka kaki.',
      'Angkat kedua-dua tangan ke atas.',
      'Kembali ke posisi asal.',
    ],
    benefits: [
      'Meningkatkan stamina.',
      'Membakar kalori.',
      'Melancarkan peredaran darah.',
    ],
    tip: 'Lakukan dengan rentak yang konsisten.',
  ),

  Workout(
    title: 'Burpees',
    durationMinutes: 8,
    difficulty: 'Sukar',
    calories: 100,
    icon: Icons.local_fire_department,
    description:
    'Burpees ialah senaman seluruh badan yang sangat efektif.',
    steps: [
      'Mulakan dalam posisi berdiri.',
      'Turun ke posisi squat.',
      'Lompat ke posisi plank.',
      'Lakukan satu Push Up.',
      'Lompat semula ke posisi squat.',
      'Lompat setinggi mungkin.',
    ],
    benefits: [
      'Membakar kalori dengan cepat.',
      'Melatih seluruh badan.',
      'Meningkatkan kecergasan.',
    ],
    tip: 'Mulakan secara perlahan jika baru belajar.',
  ),
];
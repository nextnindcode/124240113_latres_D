class Outlet {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const Outlet({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class OutletData {
  static const List<Outlet> outlets = [
    Outlet(
      name: 'Pinkie Party Mart - Ambarrukmo Plaza',
      address: 'Plaza Ambarrukmo, Yogyakarta',
      latitude: -7.782543952133258,
      longitude: 110.40141191062523,
    ),
    Outlet(
      name: 'Pinkie Party Mart - Pakuwon Mall',
      address: 'Pakuwon Mall Jogja, Sleman',
      latitude: -7.758687968516902,
      longitude: 110.39914188329499,
    ),
    Outlet(
      name: 'Pinkie Party Mart - Sleman City Hall',
      address: 'Sleman City Hall, Sleman',
      latitude: -7.71994301968698,
      longitude: 110.36188790535051,
    ),
    Outlet(
      name: 'Pinkie Party Mart - Jogja City Mall',
      address: 'Jogja City Mall, Yogyakarta',
      latitude: -7.752426238388287,
      longitude: 110.36098386829713,
    ),
    Outlet(
      name: 'Pinkie Party Mart - Klaten Town Square',
      address: 'Klaten Town Square (KLATOS), Klaten',
      latitude: -7.7032594243287695,
      longitude: 110.60275618178795,
    ),
    Outlet(
      name: 'Pinkie Party Mart - J-Walk',
      address: 'J-Walk, Yogyakarta',
      latitude: -7.779692244020403,
      longitude: 110.41431072667262,
    ),
    Outlet(
      name: 'Pinkie Party Mart - Lippo Plaza',
      address: 'Lippo Plaza, Yogyakarta',
      latitude: -7.783403532145622,
      longitude: 110.39063435139028,
    ),
    Outlet(
      name: 'Pinkie Party Mart - Plaza Malioboro',
      address: 'Plaza Malioboro, Yogyakarta',
      latitude: -7.793201574746176,
      longitude: 110.36604998894606,
    ),
    Outlet(
      name: 'Pinkie Party Mart - Galeria Mall',
      address: 'Galeria Mall, Yogyakarta',
      latitude: -7.782436130792475,
      longitude: 110.37897779435494,
    ),
  ];
}

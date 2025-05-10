class Monster {
  final int no;
  final int magic;
  final int will;
  final int intel;
  final int lv;

  Monster({
    this.no = 999,
    this.magic = 1,
    this.will = 1,
    this.intel = 1,
    this.lv = 1,
  });

  // JSON形式のMapに変換
  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'magic': magic,
      'will': will,
      'intel': intel,
      'lv': lv,
    };
  }

  Monster.fromJson(Map<String, dynamic> json)
      : no = json['no'],
        magic = json['magic'] ?? json['will'], // 後方互換性のため
        will = json['will'] ?? json['charm'], // 後方互換性のため
        intel = json['intel'],
        lv = json['lv'] ?? json['magic']; // 後方互換性のため

  @override
  String toString() {
    return 'Monster(no: $no, magic: $magic, will: $will, intel: $intel, lv: $lv)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Monster &&
          runtimeType == other.runtimeType &&
          no == other.no &&
          magic == other.magic &&
          will == other.will &&
          intel == other.intel &&
          lv == other.lv;

  @override
  int get hashCode =>
      no.hashCode ^
      magic.hashCode ^
      will.hashCode ^
      intel.hashCode ^
      lv.hashCode;
}

class HighestStatus {
  int lv = 1;
  int magic = 1;
  int will = 1;
  int intel = 1;

  HighestStatus({required List<Monster> monsters}) {
    if (monsters.isEmpty) return;

    lv = monsters[0].lv;
    magic = monsters[0].magic;
    will = monsters[0].will;
    intel = monsters[0].intel;

    for (Monster monster in monsters) {
      if (monster.lv > lv) {
        lv = monster.lv;
      }
      if (monster.magic > magic) {
        magic = monster.magic;
      }
      if (monster.will > will) {
        will = monster.will;
      }
      if (monster.intel > intel) {
        intel = monster.intel;
      }
    }
  }
}

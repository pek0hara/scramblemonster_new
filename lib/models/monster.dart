class Monster {
  final int no;
  final int hp;
  final int atk;
  final int spd;
  final int lv;

  Monster({
    this.no = 999,
    this.hp = 1,
    this.atk = 1,
    this.spd = 1,
    this.lv = 1,
  });

  // JSON形式のMapに変換
  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'hp': hp,
      'atk': atk,
      'spd': spd,
      'lv': lv,
    };
  }

  Monster.fromJson(Map<String, dynamic> json)
      : no = json['no'],
        hp = json['hp'] ?? json['magic'] ?? json['will'], // 後方互換性のため
        atk = json['atk'] ?? json['will'] ?? json['charm'], // 後方互換性のため
        spd = json['spd'] ?? json['intel'], // 後方互換性のため
        lv = json['lv'] ?? json['magic']; // 後方互換性のため

  @override
  String toString() {
    return 'Monster(no: $no, hp: $hp, atk: $atk, spd: $spd, lv: $lv)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Monster &&
          runtimeType == other.runtimeType &&
          no == other.no &&
          hp == other.hp &&
          atk == other.atk &&
          spd == other.spd &&
          lv == other.lv;

  @override
  int get hashCode =>
      no.hashCode ^
      hp.hashCode ^
      atk.hashCode ^
      spd.hashCode ^
      lv.hashCode;
}

class HighestStatus {
  int lv = 1;
  int hp = 1;
  int atk = 1;
  int spd = 1;

  HighestStatus({required List<Monster> monsters}) {
    if (monsters.isEmpty) return;

    lv = monsters[0].lv;
    hp = monsters[0].hp;
    atk = monsters[0].atk;
    spd = monsters[0].spd;

    for (Monster monster in monsters) {
      if (monster.lv > lv) {
        lv = monster.lv;
      }
      if (monster.hp > hp) {
        hp = monster.hp;
      }
      if (monster.atk > atk) {
        atk = monster.atk;
      }
      if (monster.spd > spd) {
        spd = monster.spd;
      }
    }
  }
}

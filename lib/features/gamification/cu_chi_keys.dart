/// Cu Chi discovery / tour keys — keep aligned with FE `saBanFragment.ts`.
const String cuChiLocationId = '11111111-1111-1111-1111-111111111111';

const String tramXaPanoramaId = '22222222-2222-2222-2222-222222222226';
const String tramXaQuestKey = 'tour:tram-xa';

const String saBanQuestKey = 'tour:sa-ban';
const String saBanFragmentCode = 'SABAN-3T';

const String kitchenSceneId = '22222222-2222-2222-2222-222222222221';
const String meetingSceneId = '22222222-2222-2222-2222-222222222223';

const String kitchenSceneKey = 'scene:$kitchenSceneId';
const String meetingSceneKey = 'scene:$meetingSceneId';

const String devQuestId = '33333333-3333-3333-3333-333333333336';

bool isClinicPanorama({required String id, String? title}) {
  if (id == tramXaPanoramaId) return true;
  final t = (title ?? '').toLowerCase();
  return t.contains('trạm xá') || t.contains('tram xa');
}

bool messageHasSaBanCode(String text) =>
    text.toUpperCase().contains(saBanFragmentCode);

class SaBanQuiz {
  static const prompt = 'Tầng sâu nhất của địa đạo sâu bao nhiêu?';
  static const correctId = 'deep';
  static const options = <({String id, String label})>[
    (id: 'deep', label: '8–10 m, tối đa 12 m'),
    (id: 'mid', label: '15 m'),
    (id: 'far', label: '25–30 m'),
  ];
}

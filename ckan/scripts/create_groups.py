import ckan.model as model
import ckan.logic as logic

def get_sysadmin_user():
    """İlk sistem yöneticisini bul"""
    admins = model.Session.query(model.User).filter(model.User.sysadmin == True).first()
    return admins.name if admins else None

def create_groups():
    """Grupları oluştur"""
    groups = [
        {
            'name': 'afet-acil',
            'title': 'Afet Acil Durum Yönetimi',
            'description': 'Afet ve acil durum yönetimi ile ilgili veri setleri'
        },
        {
            'name': 'altyapi',
            'title': 'Altyapı',
            'description': 'Altyapı hizmetleri ile ilgili veri setleri'
        },
        {
            'name': 'bilgi-guvenligi',
            'title': 'Bilgi Güvenliği',
            'description': 'Bilgi güvenliği ile ilgili veri setleri'
        },
        {
            'name': 'bilgi-teknolojileri',
            'title': 'Bilgi Teknolojileri',
            'description': 'Bilgi teknolojileri ile ilgili veri setleri'
        },
        {
            'name': 'cbs',
            'title': 'CBS',
            'description': 'Coğrafi Bilgi Sistemleri ile ilgili veri setleri'
        },
        {
            'name': 'cevre',
            'title': 'Çevre',
            'description': 'Çevre ile ilgili veri setleri'
        },
        {
            'name': 'ekonomi',
            'title': 'Ekonomi',
            'description': 'Ekonomi ile ilgili veri setleri'
        },
        {
            'name': 'enerji',
            'title': 'Enerji',
            'description': 'Enerji ile ilgili veri setleri'
        },
        {
            'name': 'guvenlik',
            'title': 'Güvenlik',
            'description': 'Güvenlik ile ilgili veri setleri'
        },
        {
            'name': 'iletisim',
            'title': 'İletişim',
            'description': 'İletişim ile ilgili veri setleri'
        },
        {
            'name': 'insan',
            'title': 'İnsan',
            'description': 'İnsan kaynakları ve demografik veri setleri'
        },
        {
            'name': 'mekan-yonetimi',
            'title': 'Mekan Yönetimi',
            'description': 'Mekan yönetimi ile ilgili veri setleri'
        },
        {
            'name': 'saglik',
            'title': 'Sağlık',
            'description': 'Sağlık ile ilgili veri setleri'
        },
        {
            'name': 'ulasim',
            'title': 'Ulaşım',
            'description': 'Ulaşım ile ilgili veri setleri'
        },
        {
            'name': 'yapilar',
            'title': 'Yapılar',
            'description': 'Yapılar ile ilgili veri setleri'
        },
        {
            'name': 'yonetisim',
            'title': 'Yönetişim',
            'description': 'Yönetişim ile ilgili veri setleri'
        }
    ]

    context = {
        'model': model,
        'session': model.Session,
        'user': get_sysadmin_user(),
        'ignore_auth': True
    }

    for group in groups:
        try:
            # Önce grubun var olup olmadığını kontrol et
            try:
                existing_group = logic.get_action('group_show')(context, {'id': group['name']})
                print(f"Grup zaten mevcut: {group['name']}")
                continue
            except logic.NotFound:
                pass

            # Grubu oluştur
            logic.get_action('group_create')(context, group)
            print(f"Grup başarıyla oluşturuldu: {group['name']}")
        except Exception as e:
            print(f"Hata: {group['name']} grubu oluşturulamadı - {str(e)}")

if __name__ == '__main__':
    # Model ve session'ı başlat
    model.repo.init_db()
    
    # Grupları oluştur
    print("Grup oluşturma işlemi başlıyor...")
    create_groups()
    print("İşlem tamamlandı!") 
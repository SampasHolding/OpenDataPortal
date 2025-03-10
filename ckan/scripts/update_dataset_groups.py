import ckan.lib.base as base
import ckan.model as model
import ckan.logic as logic
from ckan.common import config

def get_sysadmin_user():
    """İlk sistem yöneticisini bul"""
    admins = model.Session.query(model.User).filter(model.User.sysadmin == True).first()
    return admins.name if admins else None

def get_context():
    """API context oluştur"""
    return {
        'model': model,
        'session': model.Session,
        'user': get_sysadmin_user(),
        'ignore_auth': True
    }

def get_all_datasets():
    """Tüm datasetleri getir"""
    context = get_context()
    datasets = logic.get_action('package_list')(context, {})
    return datasets

def get_dataset_details(dataset_id):
    """Dataset detaylarını getir"""
    context = get_context()
    try:
        return logic.get_action('package_show')(context, {'id': dataset_id})
    except:
        return None

def update_dataset_group(dataset_id, group_id):
    """Dataset'in grubunu güncelle"""
    context = get_context()
    try:
        dataset = logic.get_action('package_show')(context, {'id': dataset_id})
        
        # Mevcut grupları koru ve yeni grubu ekle
        current_groups = dataset.get('groups', [])
        current_group_ids = [g['name'] for g in current_groups]
        
        if group_id not in current_group_ids:
            current_groups.append({'name': group_id})
            dataset['groups'] = current_groups
            
            logic.get_action('package_update')(context, dataset)
            print(f"Dataset {dataset_id} başarıyla {group_id} grubuna eklendi")
        else:
            print(f"Dataset {dataset_id} zaten {group_id} grubunda")
            
    except Exception as e:
        print(f"Hata: Dataset {dataset_id} güncellenemedi - {str(e)}")

def assign_groups_based_on_keywords():
    """Anahtar kelimelere göre datasetleri gruplara ata"""
    # Grup-anahtar kelime eşleştirmeleri
    group_keywords = {
        'afet-acil': ['afet', 'acil', 'deprem', 'yangın', 'sel'],
        'altyapi': ['altyapı', 'kanalizasyon', 'su', 'elektrik'],
        'bilgi-guvenligi': ['güvenlik', 'siber', 'bilgi güvenliği'],
        'bilgi-teknolojileri': ['yazılım', 'donanım', 'bilişim', 'teknoloji'],
        'cbs': ['cbs', 'coğrafi', 'harita', 'konum'],
        'cevre': ['çevre', 'iklim', 'hava', 'atık'],
        'ekonomi': ['ekonomi', 'finans', 'bütçe', 'gelir'],
        'enerji': ['enerji', 'elektrik', 'doğalgaz'],
        'guvenlik': ['güvenlik', 'asayiş', 'emniyet'],
        'iletisim': ['iletişim', 'haberleşme'],
        'insan': ['nüfus', 'demografik', 'vatandaş'],
        'mekan-yonetimi': ['bina', 'tesis', 'mekan'],
        'saglik': ['sağlık', 'hastane', 'tıbbi'],
        'ulasim': ['ulaşım', 'trafik', 'yol', 'toplu taşıma'],
        'yapilar': ['yapı', 'bina', 'inşaat'],
        'yonetisim': ['yönetim', 'idari', 'organizasyon']
    }

    datasets = get_all_datasets()
    for dataset_id in datasets:
        dataset = get_dataset_details(dataset_id)
        if not dataset:
            continue

        # Dataset başlığı ve açıklamasında anahtar kelimeleri ara
        title = dataset.get('title', '').lower()
        desc = dataset.get('notes', '').lower()
        tags = [tag['name'].lower() for tag in dataset.get('tags', [])]
        
        for group_id, keywords in group_keywords.items():
            # Eğer başlık, açıklama veya etiketlerde anahtar kelime varsa
            if any(keyword in title or keyword in desc or keyword in ' '.join(tags) for keyword in keywords):
                update_dataset_group(dataset_id, group_id)

if __name__ == '__main__':
    # Model ve session'ı başlat
    model.repo.init_db()
    
    # Gruplandırma işlemini başlat
    print("Dataset gruplandırma işlemi başlıyor...")
    assign_groups_based_on_keywords()
    print("İşlem tamamlandı!") 
"""
CKAN Veri İsteği eklentisi
"""
from flask import Blueprint, render_template, request
import os
import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
from typing import Dict, Any, List

# Blueprint'i oluştur
veri_istegi_blueprint = Blueprint('veri_istegi', __name__)

# Örnek veri - gerçek uygulamada veritabanından alınacak
VERI_ISTEKLERI = [
    {
        "title": "Şehir Planları Verisi",
        "description": "Şehir planlaması ve imar durumları hakkında detaylı veri seti.",
        "status": "Açık",
        "comment_count": 0,
        "created_date": "18.03.2024"
    },
    {
        "title": "Toplu Taşıma Güzergahları",
        "description": "Şehir içi otobüs ve metro hatlarının detaylı güzergah bilgileri.",
        "status": "Kapalı",
        "comment_count": 3,
        "created_date": "15.03.2024"
    },
    {
        "title": "Park ve Yeşil Alanlar",
        "description": "Şehirdeki park ve yeşil alanların konumları ve özellikleri.",
        "status": "Açık",
        "comment_count": 0,
        "created_date": "12.03.2024"
    },
    {
        "title": "Kültürel Etkinlikler",
        "description": "Son bir yıl içindeki kültürel etkinliklerin listesi ve katılım bilgileri.",
        "status": "Açık",
        "comment_count": 0,
        "created_date": "20.03.2024"
    },
    {
        "title": "Hava Kalitesi Ölçümleri",
        "description": "Şehir genelindeki hava kalitesi ölçüm istasyonlarının verileri.",
        "status": "Kapalı",
        "comment_count": 2,
        "created_date": "10.03.2024"
    }
]

def get_request_count(status: str) -> int:
    """
    Belirli bir durumdaki veri isteklerinin sayısını döndürür
    """
    if status == 'all':
        return len(VERI_ISTEKLERI)
    return len([v for v in VERI_ISTEKLERI if v['status'] == ('Açık' if status == 'open' else 'Kapalı')])

def get_filtered_requests(status: str = 'all', sort: str = 'newest', page: int = 1, per_page: int = 3) -> Dict[str, Any]:
    """
    Durum ve sıralama kriterlerine göre filtrelenmiş veri isteklerini döndürür
    """
    # Önce duruma göre filtrele
    if status == 'all':
        filtered_requests = VERI_ISTEKLERI.copy()
    else:
        filtered_status = 'Açık' if status == 'open' else 'Kapalı'
        filtered_requests = [v for v in VERI_ISTEKLERI if v['status'] == filtered_status]
        
    # Sıralamayı uygula
    if sort == 'newest':
        filtered_requests.sort(key=lambda x: x['created_date'], reverse=True)
    elif sort == 'oldest':
        filtered_requests.sort(key=lambda x: x['created_date'])

    # Toplam sayfa sayısını hesapla
    total_items = len(filtered_requests)
    total_pages = (total_items + per_page - 1) // per_page

    # Geçerli sayfa numarasını kontrol et
    page = max(1, min(page, total_pages))

    # Sayfalama uygula
    start_idx = (page - 1) * per_page
    end_idx = start_idx + per_page
    paginated_requests = filtered_requests[start_idx:end_idx]

    return {
        'items': paginated_requests,
        'total_items': total_items,
        'total_pages': total_pages,
        'current_page': page,
        'per_page': per_page
    }

@veri_istegi_blueprint.route('/veri-istegi')
def index():
    """
    Veri İsteği sayfasını göster
    """
    # URL parametrelerini al
    sort = request.args.get('sort', 'newest')
    status = request.args.get('status', 'all')
    organization = request.args.get('organization', None)
    page = request.args.get('page', 1, type=int)
    search_query = request.args.get('q', '')

    # Filtrelenmiş veri isteklerini al
    result = get_filtered_requests(status, sort, page)
    veri_istekleri = result['items']

    # Arama filtresini uygula
    if search_query:
        veri_istekleri = [
            v for v in veri_istekleri
            if search_query.lower() in v['title'].lower() or 
               search_query.lower() in v['description'].lower()
        ]

    # Şablona gönderilecek değişkenler
    extra_vars = {
        'veri_istekleri': veri_istekleri,
        'sort': sort,
        'status': status,
        'organization': organization,
        'page': result['current_page'],
        'total_pages': result['total_pages'],
        'search_query': search_query,
        'total_count': result['total_items']
    }

    return render_template('veriistegi/veriistegi.html', **extra_vars)

@veri_istegi_blueprint.route('/veri-istegi/<title>')
def show(title):
    """
    Veri İsteği detay sayfasını göster
    """
    # Belirtilen başlığa sahip veri isteğini bul
    veri_istegi = next((v for v in VERI_ISTEKLERI if v['title'] == title), None)
    
    if not veri_istegi:
        return render_template('error_document_template.html', 
                              error_type="404", 
                              error_message="Veri isteği bulunamadı")
    
    # Şablona gönderilecek değişkenler
    extra_vars = {
        'veri': veri_istegi
    }
    
    return render_template('veriistegi/veri_istegi_detail.html', **extra_vars)

# CKAN Plugin sınıfı
class VeriIstegiPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IBlueprint)
    plugins.implements(plugins.IConfigurer)
    plugins.implements(plugins.ITemplateHelpers)

    # IConfigurer
    def update_config(self, config_):
        # Şablon dizinini ekle
        toolkit.add_template_directory(config_, 'templates')

    # IBlueprint
    def get_blueprint(self):
        # Flask blueprint'ini döndür
        return veri_istegi_blueprint

    # ITemplateHelpers
    def get_helpers(self):
        return {
            'get_request_count': get_request_count
        } 
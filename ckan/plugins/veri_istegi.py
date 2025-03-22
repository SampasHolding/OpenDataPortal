"""
CKAN Veri İsteği eklentisi
"""
from flask import Blueprint, render_template, request, redirect, Response
import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
from typing import Dict, Any, List
import flask
import flask.typing as ft

# Blueprint'i oluştur
veri_istegi_blueprint = Blueprint('veri_istegi', __name__, url_prefix='/veri-istegi')

# User routes
user_blueprint = Blueprint('user', __name__, url_prefix='/user')

@user_blueprint.route('/<id>')
def read(id):
    """Kullanıcı profili için error sayfası göster"""
    return Response('<h1>Bu sayfa geçici olarak devre dışı</h1>', status=403)

@user_blueprint.route('/edit/<id>')
def edit(id):
    """Kullanıcı profili düzenleme için error sayfası göster"""
    return Response('<h1>Bu sayfa geçici olarak devre dışı</h1>', status=403)

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
    },
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
    # Filtre ve sayfalama ayarları
    filtered_requests = VERI_ISTEKLERI.copy()
    
    # Duruma göre filtrele
    if status != 'all':
        filtered_status = 'Açık' if status == 'open' else 'Kapalı'
        filtered_requests = [v for v in VERI_ISTEKLERI if v['status'] == filtered_status]
    
    # Sıralama
    if sort == 'newest':
        # Tarih formatı: gg.aa.yyyy
        filtered_requests = sorted(filtered_requests, key=lambda x: x['created_date'].split('.')[::-1], reverse=True)
    elif sort == 'oldest':
        filtered_requests = sorted(filtered_requests, key=lambda x: x['created_date'].split('.')[::-1])
    elif sort == 'most_commented':
        filtered_requests = sorted(filtered_requests, key=lambda x: x['comment_count'], reverse=True)
    
    # Sayfalama
    total_items = len(filtered_requests)
    total_pages = (total_items + per_page - 1) // per_page
    current_page = min(max(1, page), total_pages) if total_pages > 0 else 1
    
    start_idx = (current_page - 1) * per_page
    end_idx = min(start_idx + per_page, total_items)
    
    return {
        'items': filtered_requests[start_idx:end_idx],
        'total_items': total_items,
        'current_page': current_page,
        'total_pages': total_pages
    }


@veri_istegi_blueprint.route('/')
def veri_istegi():
    """
    Veri İsteği sayfasını göster
    """
    # URL parametrelerini al
    sort = request.args.get('sort', 'newest')
    status = request.args.get('status', 'all')
    organization = request.args.get('organization', None)
    page = request.args.get('page', 1, type=int)
    search_query = request.args.get('q', '')
    action = request.args.get('_action', None)
    
    # Eğer _action=add ise, veri isteği ekleme sayfasını göster
    if action == 'add':
        return render_template('veriistegi/veri_istegi_form.html')

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


# CKAN Plugin sınıfı
class VeriIstegiPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer)
    plugins.implements(plugins.IBlueprint)
    
    def update_config(self, config_):
        # Şablon dizinini ekle
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('assets', 'veri_istegi')
    
    def get_blueprint(self):
        # Flask blueprint'lerini döndür
        return [veri_istegi_blueprint, user_blueprint]
    
    def get_helpers(self):
        return {'get_request_count': get_request_count}
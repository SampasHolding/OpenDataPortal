# encoding: utf-8

from __future__ import annotations

from urllib.parse import urlencode
from typing import Any, Optional, List, Tuple

from flask import Blueprint, make_response, redirect, request

import ckan.logic as logic
import ckan.lib.base as base
import ckan.lib.search as search
from ckan.lib.helpers import helper_functions as h

from ckan.common import g, config, current_user, _
from ckan.types import Context, Response
from ckan.plugins.veri_istegi import get_filtered_requests

CACHE_PARAMETERS = [u'__cache', u'__no_cache__']


home = Blueprint(u'home', __name__)


def get_request_count(status: str) -> int:
    """
    Belirli bir durumdaki veri isteklerinin sayısını döndürür
    """
    # Tüm veri isteklerini al
    all_requests = get_filtered_requests('all', 'newest', 1, 999)['items']
    
    if status == 'all':
        return len(all_requests)
    
    # İstenen duruma göre filtrele ve say
    filtered_requests = [v for v in all_requests if v['status'] == ('Açık' if status == 'open' else 'Kapalı')]
    return len(filtered_requests)

# Register helper function
h.get_request_count = get_request_count


def index() -> str:
    u'''display home page'''
    extra_vars: dict[str, Any] = {}
    try:
        context: Context = {
            u'user': current_user.name,
            u'auth_user_obj': current_user
        }

        data_dict: dict[str, Any] = {
            u'q': u'*:*',
            u'facet.field': h.facets(),
            u'rows': 4,
            u'start': 0,
            u'sort': u'view_recent desc',
            u'fq': u'capacity:"public"'}
        query = logic.get_action(u'package_search')(context, data_dict)
        g.package_count = query['count']
        g.datasets = query['results']

        org_label = h.humanize_entity_type(
            u'organization',
            h.default_group_type(u'organization'),
            u'facet label') or _(u'Organizations')

        group_label = h.humanize_entity_type(
            u'group',
            h.default_group_type(u'group'),
            u'facet label') or _(u'Groups')

        g.facet_titles = {
            u'organization': org_label,
            u'groups': group_label,
            u'tags': _(u'Tags'),
            u'res_format': _(u'Formats'),
            u'license': _(u'Licenses'),
        }

        extra_vars[u'search_facets'] = query[u'search_facets']

    except search.SearchError:
        g.package_count = 0

    if current_user.is_authenticated and not current_user.email:
        url = h.url_for('user.edit')
        msg = _(u'Please <a href="%s">update your profile</a>'
                u' and add your email address. ') % url + \
            _(u'%s uses your email address'
                u' if you need to reset your password.') \
            % config.get(u'ckan.site_title')
        h.flash_notice(msg, allow_html=True)
    return base.render(u'home/index.html', extra_vars=extra_vars)


def about() -> str:
    u''' display about page'''
    return base.render(u'home/about.html', extra_vars={})


def robots_txt() -> Response:
    '''display robots.txt'''
    resp = make_response(base.render('home/robots.txt'))
    resp.headers['Content-Type'] = "text/plain; charset=utf-8"
    return resp


@home.route('/veri-istegi', methods=['GET', 'POST'])
def veri_istegi():
    """
    Veri İsteği sayfasını gösterir
    """
    # POST isteği kontrolü - Form gönderildiğinde
    if request.method == 'POST':
        # Form verilerini al
        title = request.form.get('title', '')
        description = request.form.get('description', '')
        
        if not title:
            h.flash_error(_('Başlık alanı zorunludur.'))
            return base.render('veriistegi/veri_istegi_form.html')
        
        # Veri isteğini kaydet
        from ckan.plugins.veri_istegi import VERI_ISTEKLERI
        import datetime
        
        # Yeni veri isteği oluştur
        new_request = {
            "title": title,
            "description": description,
            "status": "Açık",  # Yeni istekler default olarak açık
            "comment_count": 0,
            "created_date": datetime.datetime.now().strftime("%d.%m.%Y")
        }
        
        # Veri isteğini ekle
        VERI_ISTEKLERI.insert(0, new_request)
        
        # Başarı mesajı göster
        h.flash_success(_('Veri isteğiniz başarıyla oluşturuldu.'))
        
        # Ana veri isteği sayfasına yönlendir
        redirect_url = h.url_for('home.veri_istegi')
        return h.redirect_to(redirect_url)
    
    # URL parametrelerini al
    sort = request.args.get('sort', 'newest')
    status = request.args.get('status', 'all')
    organization = request.args.get('organization', None)
    page = request.args.get('page', 1, type=int)
    search_query = request.args.get('q', '')
    title = request.args.get('title', None)
    action = request.args.get('_action', None)
    
    # Veri isteği ekleme sayfasını göster
    if action == 'add':
        return base.render('veriistegi/veri_istegi_form.html')
    
    # Detay sayfası için belirli bir veri isteği
    if title:
        # Veri isteklerini al
        from ckan.plugins.veri_istegi import VERI_ISTEKLERI, get_filtered_requests
        
        # Belirtilen başlığa sahip veri isteğini bul
        veri_istegi = next((v for v in VERI_ISTEKLERI if v['title'] == title), None)
        
        if not veri_istegi:
            return base.render('error_document_template.html', 
                          extra_vars={
                              'error_type': "404", 
                              'error_message': "Veri isteği bulunamadı"
                          })
        
        # Şablona gönderilecek değişkenler
        extra_vars = {
            'veri': veri_istegi
        }
        
        return base.render('veriistegi/veri_istegi_detail.html', extra_vars=extra_vars)
    
    # Filtrelenmiş veri isteklerini al
    from ckan.plugins.veri_istegi import get_filtered_requests
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
    
    return base.render('veriistegi/veriistegi.html', extra_vars=extra_vars)


def redirect_locale(target_locale: str, path: Optional[str] = None) -> Any:
    target = f'/{target_locale}/{path}' if path else f'/{target_locale}'

    if request.args:
        target += f'?{urlencode(request.args)}'

    url = h.url_for(target, _external=True)

    return redirect(url, code=308)


util_rules: List[Tuple[str, Any]] = [
    (u'/', index),
    (u'/about', about),
    (u'/robots.txt', robots_txt),
    (u'/veri-istegi', veri_istegi)
]
for rule, view_func in util_rules:
    if rule == '/veri-istegi':
        home.add_url_rule(rule, 'veri_istegi', view_func=view_func)
    else:
        home.add_url_rule(rule, view_func=view_func)

locales_mapping: List[Tuple[str, str]] = [
    ('zh_TW', 'zh_Hant_TW'),
    ('zh_CN', 'zh_Hans_CN'),
    ('no', 'nb_NO'),
]

for locale in locales_mapping:

    legacy_locale = locale[0]
    new_locale = locale[1]

    home.add_url_rule(
        f'/{legacy_locale}/',
        view_func=redirect_locale,
        defaults={'target_locale': new_locale}
    )

    home.add_url_rule(
        f'/{legacy_locale}/<path:path>',
        view_func=redirect_locale,
        defaults={'target_locale': new_locale}
    )

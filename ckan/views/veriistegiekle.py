from flask import Blueprint, request, redirect, url_for, jsonify
from ckan.common import _, g
import ckan.lib.base as base
import ckan.lib.helpers as h
import ckan.logic as logic
import ckan.model as model
from typing import Dict, List, Optional, Union, Any
import logging

log = logging.getLogger(__name__)

# Blueprint'i tanımla
veriistegi = Blueprint('veriistegi', __name__)

@veriistegi.route('/veri-istegi-ekle', methods=['GET', 'POST'])
def veri_istegi_ekle():
    '''
    Veri isteği ekleme formunu gösterir ve form gönderimlerini işler
    '''
    # Kullanıcı giriş yapmadıysa giriş sayfasına yönlendir
    if not g.user:
        h.flash_error(_('Veri isteği eklemek için lütfen giriş yapın.'))
        return redirect(url_for('user.login'))
    
    if request.method == 'POST':
        try:
            # Form verilerini al
            title = request.form.get('title', '')
            description = request.form.get('description', '')
            organization = request.form.get('organization', '')
            
            # Form doğrulama
            if not title or not description:
                h.flash_error(_('Başlık ve açıklama alanları zorunludur.'))
                return base.render('veriistegi/veri_istegi_ekle.html')
            
            # TODO: Veri isteğini veritabanına kaydet
            # Örnek: 
            # data_dict = {
            #     'title': title,
            #     'description': description,
            #     'organization': organization,
            #     'user_id': g.userobj.id
            # }
            # logic.get_action('veri_istegi_create')(context, data_dict)
            
            # Şimdilik başarılı mesajı göster
            h.flash_success(_('Veri isteğiniz başarıyla oluşturuldu.'))
            return redirect(url_for('veriistegi.veri_istegi_ekle'))
            
        except Exception as e:
            log.error('Veri isteği oluşturulurken hata: %s', str(e))
            h.flash_error(_('Veri isteği oluşturulurken bir hata oluştu.'))
    
    # GET isteği veya POST hatası durumunda formu göster
    return base.render('veriistegi/veri_istegi_ekle.html')

# Blueprint'i kaydeden kod __init__.py dosyasında olmalı

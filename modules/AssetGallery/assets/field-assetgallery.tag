<field-assetgallery>
    <div ref="uploadprogress" class="uk-margin uk-hidden">
        <div class="uk-progress">
            <div ref="progressbar" class="uk-progress-bar" style="width: 0%;">&nbsp;</div>
        </div>
    </div>
    <div ref="panel">
        <div ref="assetscontainer" class="uk-sortable uk-grid uk-grid-match uk-grid-small uk-flex-center uk-grid-gutter uk-grid-width-medium-1-4" show="{ assets && assets.length }">
            <div data-idx="{ idx }" each="{ ast,idx in assets }">
                <div class="uk-panel uk-panel-box uk-panel-thumbnail uk-panel-framed uk-visible-hover">
                        <div class="uk-bg-transparent-pattern uk-position-relative" style="min-height:120px;">
                            <canvas class="uk-responsive-width" width="200" height="150"></canvas>
                            <div class="uk-position-absolute uk-position-cover uk-flex uk-flex-middle">
                                <div class="uk-width-1-1 uk-text-center">
                                    <cp-thumbnail src="{ ast.path.match(/^(http\:|https\:|\/\/)/) ? ast.path : (SITE_URL+'/'+ast.path.replace(/^\//, '')) }" height="120"></cp-thumbnail>
                                </div>
                            </div>
                        </div>
                        <div class="uk-invisible uk-margin-top">
                            <ul class="uk-grid uk-grid-small uk-flex-center uk-text-small">
                                <li data-uk-dropdown="pos:'bottom-center'">
                                    <a class="uk-text-muted" onclick="{ parent.selectAsset }" title="{ App.i18n.get('Select asset') }" data-uk-tooltip><i class="uk-icon-asset"></i></a>
                                    <div class="uk-dropdown">
                                        <ul class="uk-nav uk-nav-dropdown uk-dropdown-close">
                                            <li class="uk-nav-header">{ App.i18n.get('Source') }</li>
                                            <li><a onclick="{ parent.selectAsset }">{ App.i18n.get('Select Asset') }</a></li>
                                        </ul>
                                    </div>
                                </li>
                                <li><a class="uk-text-muted" onclick="{ parent.showMeta }" title="{ App.i18n.get('Edit meta data') }" data-uk-tooltip><i class="uk-icon-cog"></i></a></li>
                                <li><a class="uk-text-muted" href="{ ast.path.match(/^(http\:|https\:|\/\/)/) ? ast.path : (SITE_URL+'/'+ast.path.replace(/^\//, '')) }" data-uk-lightbox title="{ App.i18n.get('Full size') }" data-uk-tooltip><i class="uk-icon-eye"></i></a></li>
                                <li><a class="uk-text-danger" onclick="{ parent.remove }" title="{ App.i18n.get('Remove asset') }" data-uk-tooltip><i class="uk-icon-trash-o"></i></a></li>
                            </ul>
                        </div>
                </div>
            </div>
        </div>
        <div class="uk-text-center {assets && assets.length ? 'uk-margin-top':'' }">
            <div class="uk-text-muted" if="{ assets && !assets.length }">
                <img class="uk-svg-adjust" riot-src="{ App.base('/assets/app/media/icons/gallery.svg') }" width="100" data-uk-svg>
                <p>{ App.i18n.get('Asset Gallery is empty') }</p>
            </div>
            <div class="uk-display-inline-block uk-position-relative" data-uk-dropdown="pos:'bottom-center'">
                <a class="uk-text-large" onclick="{ selectAssets }">
                    <i class="uk-icon-plus-circle" title="{ App.i18n.get('Add assets') }" data-uk-tooltip></i>
                </a>
            </div>
        </div>
        <div class="uk-modal uk-sortable-nodrag" ref="modalmeta">
            <div class="uk-modal-dialog">
                <div class="uk-modal-header"><h3>{ App.i18n.get('Asset MetaData') }</h3></div>
                <div class="uk-grid uk-grid-match uk-grid-gutter" if="{asset}">
                    <div class="uk-grid-margin uk-width-medium-{field.width}" each="{field,name in meta}" no-reorder>
                        <div class="uk-panel">
                            <label class="uk-text-small uk-text-bold">
                                <i class="uk-icon-pencil-square uk-margin-small-right"></i> { field.label || name }
                            </label>
                            <div class="uk-margin uk-text-small uk-text-muted">
                                { field.info || ' ' }
                            </div>
                            <div class="uk-margin">
                                <cp-field type="{ field.type || 'text' }" bind="asset.meta['{name}']" opts="{ field.options || {} }"></cp-field>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="uk-modal-footer uk-text-right"><button class="uk-button uk-button-large uk-button-link uk-modal-close">{ App.i18n.get('Close') }</button></div>
            </div>
        </div>
    </div>

	<script>
		riot.util.bind(this);

		var $this = this;

		this.assets = [];
		this._field = null;
		this.meta = {
			title: {
				type: 'text',
				label: 'Title'
			}
		};

		this.on('mount', function() {
			this.meta = App.$.extend(this.meta, opts.meta || {});

			UIkit.sortable(this.refs.assetscontainer, {
				animation: false
			}).element.on('change.uk.sortable', function(e, sortable, ele) {
				ele = App.$(ele);

				var assets = $this.assets,
					cidx   = ele.index(),
					oidx   = ele.data('idx');

				assets.splice(cidx, 0, assets.splice(oidx, 1)[0]);

				// hack to force complete assets rebuild
				App.$($this.refs.panel).css('height', App.$($this.refs.panel).height());

				$this.assets = [];
				$this.update();

				setTimeout(function() {
					$this.assets = assets;
					$this.$setValue(assets);
					$this.update();

					setTimeout(function(){
						$this.refs.panel.style.height = '';
						$this.update();
					}, 30)
				}, 10);
			});

			// handle uploads
			var _uploads = [];
			App.assets.require(['/assets/lib/uikit/js/components/upload.js'], function() {
				UIkit.uploadDrop($this.root, {
					action: App.route('/assetsmanager/upload'),
					type: 'json',
					allow : '*.*',
					beforeAll: function() {
						_uploads = [];
					},
					loadstart: function() {
						$this.refs.uploadprogress.classList.remove('uk-hidden');
					},
					progress: function(percent) {
						percent = Math.ceil(percent) + '%';
						$this.refs.progressbar.innerHTML   = '<span>'+percent+'</span>';
						$this.refs.progressbar.style.width = percent;
					},
					complete: function(response) {
						if (response && response.failed && response.failed.length) {
							App.ui.notify("File(s) failed to upload.", "danger");
						}

						if (response && Array.isArray(response.assets) && response.assets.length) {
							response.assets.forEach(function(asset){
									_uploads.push({
										meta:{title:'', asset: asset._id},
										path: ASSETS_URL.replace(SITE_URL, '')+asset.path
									});
							});
						}

						if (!response) {
							App.ui.notify("Something went wrong.", "danger");
						}
					},

					allcomplete: function(response) {
						$this.refs.uploadprogress.classList.add('uk-hidden');

						if (Array.isArray(_uploads) && _uploads.length) {
							$this.$setValue($this.assets.concat(_uploads));
						}
					}
				});
			});

		});

		this.$updateValue = function(value, field) {
			if (!Array.isArray(value)) {
				value = [];
			}

			if (JSON.stringify(this.assets) !== JSON.stringify(value)) {
				this.assets = value;
				this.update();
			}
		}.bind(this);

		this.$initBind = function() {
			this.root.$value = this.assets;
		};

		this.on('bindingupdated', function() {
			$this.$setValue(this.assets);
		});

		showMeta(e) {
			this.asset = this.assets[e.item.idx];

			setTimeout(function() {
				UIkit.modal($this.refs.modalmeta, {modal:false}).show().on('close.uk.modal', function(){
					$this.asset = null;
				});
			}, 50)
		}

		selectAssets() {
			App.assets.select(function(assets){
				if (Array.isArray(assets)) {
					var list = [];

					assets.forEach(function(asset){
						list.push({
							meta:{title:'', asset: asset._id},
							path: ASSETS_URL.replace(SITE_URL, '')+asset.path
						});
					});

					$this.$setValue($this.assets.concat(list));
				}
			});
		}

        selectAsset(e) {
            var asset = e.item.img;

            App.assets.select(function(assets){
                if (Array.isArray(assets) && assets[0]) {
                    asset.path = ASSETS_URL.replace(SITE_URL, '')+assets[0].path;
                    $this.$setValue($this.assets);
                    $this.update();
                }
            });
        }

        remove(e) {
            this.assets.splice(e.item.idx, 1);
            this.$setValue(this.assets);
        }
    </script>
</field-assetgallery>

class Export
	def self.create
		ret = ""
		for c in Category.all
			ret += "Category.create({"
			ret += "\n\tid: #{c.id},"
			ret += "\n\tname: \"#{c.name}\","
			ret += "\n\tdescription: \"#{c.description}\","
			ret += "\n\tposition: #{c.position},"
			ret += "\n\theader: \"#{c.header}\","
			ret += "\n\tcategory_id: #{c.parent_id || 'nil'},"
			ret += "\n\tseo_title: \"#{c.s_title}\","
			ret += "\n\tseo_description: \"#{c.s_description}\","
			ret += "\n\tseo_keywords: \"#{c.s_keyword}\","
			ret += "\n\tseo_text: \"#{c.seo_text}\","
			ret += "\n\ts_name: \"#{c.s_name}\","
			ret += "\n\tscode: \"#{c.scode}\","
			ret += "\n\tcommission: #{c.commission},"
			ret += "\n\trate: #{c.rate},"
			ret += "\n\turl: \"#{c.url}\","
			ret += "\n\tmenu: #{c.menu || 'nil'},"
			ret += "\n\tisMobile: #{if c.isMobile == nil then 'nil' else c.isMobile end},"
			ret += "\n\tmobile_image_url: \"#{c.mobile_image_url}\""
			ret += "\n})\n\n"
		end
		for c in Subcategory.all
			ret += "Subcategory.create({"
			ret += "\n\tid: #{c.id},"
			ret += "\n\tname: \"#{c.name}\","
			ret += "\n\tdescription: \"#{c.description}\","
			ret += "\n\tcategory_id: #{c.category_id}"
			ret += "\n})\n\n"
		end
		for c in SubCatImage.all
			ret += "SubcategoryItem.create({"
			ret += "\n\timage: \"#{c.url}\","
			ret += "\n\tdescription: \"c.description\","
			ret += "\n\tsubcategory_id: \"#{c.subcategory_id}\""
			ret += "\n})\n\n"
		end
		for c in Product.all
			ret += "product = Product.create({"
			ret += "\n\tid: #{c.id},"
			ret += "\n\tcategory_id: #{c.category_id || 'nil'},"
			category_ids = []
			for id in c.category_ids
				category_ids << id if Category.find(id)
			end
			ret += "\n\tcategory_ids: #{category_ids},"
			ret += "\n\tscode: \"#{c.scode}\","
			ret += "\n\tname: \"#{c.name}\","
			ret += "\n\tdescription: #{if c.description then c.description.dump else "\"\"" end},"
			ret += "\n\tshortdesk: #{if c.shortdesk then c.shortdesk.dump else "\"\"" end},"
			ret += "\n\tdelemiter: #{if c.delemiter == nil then 'nil' else c.delemiter end},"
			ret += "\n\tinvisible: #{if c.invisible == nil then 'nil' else c.invisible end},"
			ret += "\n\tmain: #{if c.main == nil then 'nil' else c.main end},"
			ret += "\n\taction: #{if c.action == nil then 'nil' else c.action end},"
			ret += "\n\tbest: #{if c.best == nil then 'nil' else c.best end},"
			ret += "\n\tposition: #{c.position || 'nil'},"
			ret += "\n\tseo_title: \"#{c.s_title}\","
			ret += "\n\tseo_description: \"#{c.s_description}\","
			ret += "\n\tseo_keywords: \"#{c.s_keyword}\","
			ret += "\n\tseo_imagealt: \"#{c.s_imagealt}\","
			ret += "\n\tseo_text: \"#{c.seo_text}\","
			ret += "\n\tprice: #{c.price},"
			ret += "\n\told_price: #{c.old_price},"
			ret += "\n\tseo_title2: \"#{c.seo_title2}\","
			ret += "\n\tsubcategory_id: #{c.subcategory_id || 'nil'},"
			ret += "\n\tarticle: \"#{c.article}\","
			ret += "\n\textension_id: \"#{c.extension_id || 'nil'}\""
			ret += "\n})\n\n"
			if c.images
				for i in c.images.split(',')
					ret += "product.images.create({"
					ret += "\n\turl: \"#{i}\""
					ret += "\n})\n\n"
				end
			end
		end
		for c in Extension.all
			ret += "Extension.create({"
			ret += "\n\tid: #{c.id},"
			ret += "\n\tname: \"#{c.name}\","
			ret += "\n\timage: \"#{c.image}\""
			ret += "\n})\n\n"
		end
		for c in Prsize.all
			ret += "Size.create({"
			ret += "\n\tid: #{c.id},"
			ret += "\n\tproduct_id: #{c.product_id || 'nil'},"
			ret += "\n\tname: \"#{c.name}\","
			ret += "\n\tscode: \"#{c.scode}\","
			ret += "\n\tprice: #{c.price}"
			ret += "\n})\n\n"
		end
		for c in Prcolor.all
			ret += "Color.create({"
			ret += "\n\tid: #{c.id},"
			ret += "\n\tsize_id: #{c.prsize_id},"
			ret += "\n\tname: \"#{c.name}\","
			ret += "\n\tscode: \"#{c.scode}\","
			ret += "\n\timage: \"#{c.images}\","
			ret += "\n\tdescription: #{if c.description then c.description.dump else "\"\"" end},"
			ret += "\n\tprice: #{c.price}"
			ret += "\n})\n\n"
		end
		for c in Texture.all
			if c.prcolor_id
				ret += "Texture.create({"
				ret += "\n\tid: #{c.id},"
				ret += "\n\tcolor_id: #{c.prcolor_id},"
				ret += "\n\tname: \"#{c.name}\","
				ret += "\n\tscode: \"#{c.scode}\","
				ret += "\n\timage: \"#{c.image}\","
				ret += "\n\tprice: #{c.price}"
				ret += "\n})\n\n"
			end
		end
		for c in Proption.all
			ret += "Option.create({"
			ret += "\n\tid: #{c.id},"
			ret += "\n\tsize_id: #{c.prsize_id},"
			ret += "\n\tname: \"#{c.name}\","
			ret += "\n\tscode: \"#{c.scode}\","
			ret += "\n\tprice: #{c.price}"
			ret += "\n})\n\n"
		end
		File.write Rails.root.join('public', 'seeds.rb'), ret
	end
end

class CreateTextures < ActiveRecord::Migration
  def change
    create_table :textures do |t|
    	t.belongs_to :color
    	t.string :name
    	t.string :scode
    	t.string :image
    	t.decimal :price, precision: 18, scale: 2, default: 0.0
    end

    add_index :textures, :scode, unique: true
  end
end

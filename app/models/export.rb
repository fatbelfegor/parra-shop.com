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
			ret += "\n\tseo_title: \"#{c.seo_title2}\","
			ret += "\n\tseo_description: \"#{c.s_description}\","
			ret += "\n\tseo_keywords: \"#{c.s_keyword}\","
			ret += "\n\tseo_imagealt: \"#{c.s_imagealt}\","
			ret += "\n\tseo_text: \"#{c.seo_text}\","
			ret += "\n\tprice: #{c.price},"
			ret += "\n\told_price: #{c.old_price},"
			ret += "\n\ttitle: \"#{c.s_title}\","
			ret += "\n\tsubcategory_id: #{c.subcategory_id || 'nil'},"
			ret += "\n\tarticle: \"#{c.article}\","
			ret += "\n\textension_id: \"#{c.extension_id || 'nil'}\","
			ret += "\n\tcreated_at: \"#{c.created_at || 'nil'}\""
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
		for c in Status.all
			ret += "Status.create({"
			ret += "\n\tid: #{c.id},"
			ret += "\n\tname: \"#{c.name}\""
			ret += "\n})\n\n"
		end
		for c in Order.all
			ret += "Order.create({"
			ret += "\n\tid: #{c.id},"
			ret += "\n\tfirst_name: \"#{c.first_name}\","
		    ret += "\n\tmiddle_name: \"#{c.middle_name}\","
		    ret += "\n\tlast_name: \"#{c.last_name}\","
		    ret += "\n\tgender: \"#{c.gender}\","
		    ret += "\n\tphone: \"#{c.phone}\","
		    ret += "\n\temail: \"#{c.email}\","
		    ret += "\n\tpay_type: \"#{c.pay_type}\","
		    ret += "\n\taddr_street: \"#{c.addr_street}\","
		    ret += "\n\taddr_home: \"#{c.addr_home}\","
		    ret += "\n\taddr_block: \"#{c.addr_block}\","
		    ret += "\n\taddr_flat: \"#{c.addr_flat}\","
		    ret += "\n\tcreated_at: \"#{c.created_at}\","
		    ret += "\n\tcomment: #{if c.comment then c.comment.dump else "\"\"" end},"
		    ret += "\n\tsalon: \"#{c.salon}\","
		    ret += "\n\tsalon_tel: \"#{c.salon_tel}\","
		    ret += "\n\tmanager: \"#{c.manager}\","
		    ret += "\n\tmanager_tel: \"#{c.manager_tel}\","
		    ret += "\n\taddr_metro: \"#{c.addr_metro}\","
		    ret += "\n\taddr_staircase: \"#{c.addr_staircase}\","
		    ret += "\n\taddr_floor: \"#{c.addr_floor}\","
		    ret += "\n\taddr_code: \"#{c.addr_code}\","
		    ret += "\n\taddr_elevator: \"#{c.addr_elevator}\","
		    ret += "\n\tdeliver_type: \"#{c.deliver_type}\","
		    ret += "\n\tdeliver_cost: #{c.deliver_cost || 'nil'},"
		    ret += "\n\tprepayment_date: \"#{c.prepayment_date}\","
		    ret += "\n\tprepayment_sum: #{c.prepayment_sum || 'nil'},"
		    ret += "\n\tdoppayment_date: \"#{c.doppayment_date}\","
		    ret += "\n\tdoppayment_sum: #{c.doppayment_sum || 'nil'},"
		    ret += "\n\tfinalpayment_date: \"#{c.finalpayment_date}\","
		    ret += "\n\tfinalpayment_sum: #{c.finalpayment_sum || 'nil'},"
		    ret += "\n\tpayment_type: \"#{c.payment_type}\","
		    ret += "\n\tcredit_sum: #{c.credit_sum || 'nil'},"
		    ret += "\n\tcredit_month: #{c.credit_month || 'nil'},"
		    ret += "\n\tcredit_procent: #{c.credit_procent || 'nil'},"
		    ret += "\n\tdeliver_date: \"#{c.deliver_date}\","
		    ret += "\n\tstatus_id: #{c.status_id || 'nil'},"
		    ret += "\n\tnumber: #{c.number || 'nil'}"
			ret += "\n})\n\n"
		end
		for c in OrderItem.all
			ret += "OrderItem.create({"
			ret += "\n\tid: #{c.id},"
		    ret += "\n\tproduct_id: #{c.product_id || 'nil'},"
		    ret += "\n\tquantity: #{c.quantity || 'nil'},"
		    ret += "\n\tprice: #{c.price || 'nil'},"
		    ret += "\n\tsize: \"#{c.size}\","
		    ret += "\n\tcolor: \"#{c.color}\","
		    ret += "\n\toption: \"#{c.option}\","
		    ret += "\n\tcreated_at: \"#{c.created_at}\","
		    ret += "\n\torder_id: #{c.order_id || 'nil'},"
		    ret += "\n\tsize_scode: \"#{c.size_scode}\","
		    ret += "\n\tcolor_scode: \"#{c.color_scode}\","
		    ret += "\n\toption_scode: \"#{c.option_scode}\","
		    ret += "\n\tdiscount: #{c.discount || 'nil'},"
			ret += "\n})\n\n"
		end
		for c in Status.all
			ret += "Status.create({"
			ret += "\n\tid: #{c.id},"
		    ret += "\n\ttext: #{if c.text then c.text.dump else "\"\"" end},"
		    ret += "\n\tprice: #{c.price || 'nil'},"
		    ret += "\n\torder_id: #{c.order_id || 'nil'}"
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

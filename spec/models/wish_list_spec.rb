require 'spec_helper'

describe WishList do
  it { should belong_to(:user)}
  it { should have_many(:wish_list_items).dependent(:destroy)}

  describe "#owner_by?" do
  	let!(:owner) {create(:user)}
    it "return true if wish_list is owner by user " do
      wish_list = WishList.new(name: "810", user_id: owner.id)
      expect(wish_list.owner_by?(owner)).to be_true
    end
    it "return false if wish_list is not owner by user" do 
    	user = create(:user)
    	wish_list = WishList.new(name: "000", user_id: user.id)
    	expect(wish_list.owner_by?(owner)).to be_false
    end
  end

end

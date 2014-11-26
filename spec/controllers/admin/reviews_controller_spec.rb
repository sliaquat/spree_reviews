RSpec.describe Spree::Admin::ReviewsController, type: :controller do
  stub_authorization!

  let(:product) { create(:product) }
  let(:review) { create(:review, approved: false) }

  before do
    user = create(:admin_user)
    allow(controller).to receive(:try_spree_current_user).and_return(user)
  end

  context '#index' do
    it 'lists reviews' do
      reviews = [
        create(:review, product: product),
        create(:review, product: product)
      ]
      spree_get :index, product_id: product.slug
      expect(assigns[:reviews]).to match_array(reviews)
    end
  end

  context '#approve' do
    it 'shows notice message when approved' do
      review.update_attribute(:approved, true)
      spree_get :approve, id: review.id
      expect(response).to redirect_to spree.admin_reviews_path
      expect(flash[:notice]).to eq Spree.t(:info_approve_review)
    end

    it 'shows error message when not approved' do
      allow_any_instance_of(Spree::Review).to receive(:update_attribute).and_return(false)
      spree_get :approve, id: review.id
      expect(flash[:error]).to eq Spree.t(:error_approve_review)
    end
  end

  context '#edit' do
    specify do
      spree_get :edit, id: review.id
      expect(response.status).to be(200)
    end

    context 'when product is nil' do
      before do
        review.product = nil
        review.save!
      end

      it 'flashes error' do
        spree_get :edit, id: review.id
        expect(flash[:error]).to eq Spree.t(:error_no_product)
      end

      it 'redirects to admin-reviews page' do
        spree_get :edit, id: review.id
        expect(response).to redirect_to spree.admin_reviews_path
      end
    end
  end
end

class IWillWriteController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def create
    pq_to_dup = Pq.find_by(uin: params[:id])

    if !pq_to_dup.i_will_write
      return redirect_to action:'pqs', controller: 'show', id: params[:id], notice: 'Error, the PQ is not flag as a \'I will write\''
    end

    uin_iww = "#{pq_to_dup.uin}-IWW"
    exist = Pq.find_by(uin: uin_iww)
    if !exist.nil?
      return redirect_to controller:'pqs', action: 'show', id: uin_iww, notice: "Created PQ 'I will write' #{uin_iww}"
    end

    @pq = pq_to_dup.dup
    @pq.uin = uin_iww
    @pq.progress_id = Progress.draft_pending.id


    if @pq.save
      # duplicate commissioning data
      ao_pq = action_officer_pq_accepted(pq_to_dup)
      if !ao_pq.nil?
        ao_pq.pq_id = @pq.id
        ao_pq.save()
      end
      return redirect_to controller:'pqs', action: 'show', id: uin_iww, notice: "Created PQ 'I will write' #{uin_iww}"
    end
    return redirect_to controller:'pqs', action: 'show', id: params[:id], notice: 'Error saving the PQ \'I will write\''
  end


  private
  def action_officer_pq_accepted(pq)
    pq.action_officers_pq.each do |ao_pq|
      if ao_pq.accept
        return ao_pq
      end
    end
    return nil
  end

end
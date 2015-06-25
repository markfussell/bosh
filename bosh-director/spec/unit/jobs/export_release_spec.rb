require 'spec_helper'

module Bosh::Director
  describe Jobs::ExportRelease do
    let(:snapshots) { [Models::Snapshot.make(snapshot_cid: 'snap0'), Models::Snapshot.make(snapshot_cid: 'snap1')] }

    subject(:job) { described_class.new("deployment_name", "release_name", "release_version", "stemcell_os", "stemcell_version") }

    context 'when the requested release does not exist' do
      it 'fails with the expected error' do
        expect {
          job.perform
        }.to raise_error(Bosh::Director::ReleaseNotFound)
      end
    end

    context 'when the requested release exists but release version does not exist' do
      before { Bosh::Director::Models::Release.create(name: 'release_name') }

      it 'fails with the expected error' do
        expect {
          job.perform
        }.to raise_error(Bosh::Director::ReleaseVersionNotFound)
      end
    end

    context 'when the requested release and version exist' do
      before {
        release = Bosh::Director::Models::Release.create(name: 'release_name')
        release.add_version(:version => 'release_version')
      }

      context 'and the requested stemcell is not found' do
        it 'fails with the expected error' do
          expect {
            job.perform
          }.to raise_error(Bosh::Director::StemcellNotFound)
        end
      end

      context 'and the requested stemcell is found' do
        before {
          Bosh::Director::Models::Stemcell.create(
              name: 'my-stemcell-with-a-name',
              version: 'stemcell_version',
              operating_system: 'stemcell_os',
              cid: 'cloud-id-a',
          )
        }

        it 'succeeds' do
          expect {
            job.perform
          }.to_not raise_error
        end

        context 'and multiple stemcells match the requested stemcell' do
          before {
            Bosh::Director::Models::Stemcell.create(
                name: 'my-stemcell-with-b-name',
                version: 'stemcell_version',
                operating_system: 'stemcell_os',
                cid: 'cloud-id-b',
            )
          }

          it 'succeeds' do
            expect {
              job.perform
            }.to_not raise_error
          end

          it 'chooses the first stemcell alhpabetically by name' do
            job.perform
            expect(log_string).to match /Will compile with stemcell: my-stemcell-with-a-name/
          end
        end
      end
    end
  end
end